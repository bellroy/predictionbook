# frozen_string_literal: true

require 'spec_helper'

describe 'predictions/show.html.erb' do
  let(:user) { FactoryBot.create(:user, name: 'person who created it', login: 'login.name') }
  let(:prediction) { FactoryBot.create(:prediction, creator: user) }
  let(:prediction_response) { FactoryBot.build(:response, prediction: prediction, user: user) }

  before do
    assign(:prediction, prediction)
    assign(:events, [])
    assign(:prediction_response, prediction_response)
    assign(:deadline_notification, FactoryBot.create(:deadline_notification))
    assign(:response_notification, FactoryBot.create(:response_notification))
    assign(:edit_path, edit_prediction_path(prediction))

    allow(view).to receive(:current_user).and_return(user)
  end

  it 'has a heading of the predicitons description' do
    allow(prediction).to receive(:description).and_return('Prediction Heading')
    render
    expect(rendered).to have_css('h1', text: 'Prediction Heading')
  end

  context 'when the user is' do
    context 'not authorized to edit the prediction' do
      before do
        allow(user)
          .to receive(:authorized_for?)
          .with(prediction, 'edit')
          .and_return(false)
        render
      end

      it 'will not render the edit button' do
        expect(rendered).not_to have_css('a', class: 'edit')
      end
    end

    context 'authorized to edit the prediction' do
      before do
        allow(user)
          .to receive(:authorized_for?)
          .with(prediction, 'edit')
          .and_return(true)
        render
      end

      it 'will render the edit button' do
        expect(rendered).to have_css('a', class: 'edit')
      end
    end
  end

  describe 'creation time' do
    before do
      @time = 3.days.ago
      expect(prediction).to receive(:created_at).and_return(@time)
      render
    end

    it 'shows when it was created' do
      expect(rendered).to have_css('span', text: '3 days ago')
    end

    it 'puts the complete date in the title attribute of the span' do
      expect(rendered).to have_selector("span[title='#{@time}']")
    end
  end

  describe 'prediction creator' do
    it 'shows who made the prediction' do
      render
      expect(rendered).to have_css('.user', text: user.name)
    end
  end

  describe 'outcome date' do
    before do
      @time = 10.days.from_now
      expect(prediction).to receive(:deadline).and_return(@time)
      render
    end

    it 'shows when the outcome will be known' do
      expect(rendered).to have_css('span', text: /10 days/)
    end
    it 'puts the complete date in the title attribute of the span' do
      expect(rendered).to have_selector("span[title='#{@time}']")
    end
  end

  it 'renders the events partial' do
    render
    expect(view).to render_template(partial: 'predictions/_events')
  end

  describe 'confirming prediction outcome' do
    describe 'outcome form' do
      describe 'if not logged in' do
        it 'does not exist' do
          render
          expect(rendered).not_to have_selector('form[action="/predictions/1/judge"]')
        end
      end

      describe 'if logged in but prediction is withdrawn' do
        it 'does not exist' do
          allow(prediction).to receive(:withdrawn?).and_return(true)
          render
          expect(rendered).not_to have_selector('form[action="/predictions/1/judge"]')
        end
      end

      describe 'if logged in' do
        before do
          allow(prediction).to receive(:to_param).and_return('1')
        end

        describe 'form and submit tags' do
          before do
            render
          end

          it 'has a form tag that submits to outcome' do
            expect(rendered).to have_selector('form[method="post"][action="/predictions/1/judge"]')
          end

          it 'has a right button' do
            expect(rendered).to have_selector('input[type="submit"][name="outcome"][value="Right"]')
          end

          it 'has a wrong button' do
            expect(rendered).to have_selector('input[type="submit"][name="outcome"][value="Wrong"]')
          end

          it 'has a unknown button' do
            expect(rendered).to have_selector('input[type="submit"][name="outcome"][value="Unknown"]')
          end
        end

        describe 'button state' do
          it 'disables the right button when the prediction is right' do
            allow(prediction).to receive(:right?).and_return(true)
            render
            expect(rendered).to have_selector('input[type="submit"][value="Right"][disabled="disabled"]')
          end

          it 'does not disable the right button when the prediction is not right' do
            allow(prediction).to receive(:right?).and_return(false)
            render
            expect(rendered).to have_selector('input[type="submit"][value="Right"]:not([disabled="disabled"])')
          end

          it 'disables the wrong button when the prediction is wrong' do
            allow(prediction).to receive(:wrong?).and_return(true)
            render
            expect(rendered).to have_selector('input[type="submit"][value="Wrong"][disabled="disabled"]')
          end

          it 'does not disable the wrong button when the prediction is not wrong' do
            allow(prediction).to receive(:wrong?).and_return(false)
            render
            expect(rendered).to have_selector('input[type="submit"][value="Wrong"]:not([disabled="disabled"])')
          end

          it 'disables the unknown button when the prediction is unknown' do
            allow(prediction).to receive(:unknown?).and_return(true)
            render
            expect(rendered).to have_selector('input[type="submit"][value="Unknown"][disabled="disabled"]')
          end

          it 'does not disable the unknown button when the prediction is known' do
            allow(prediction).to receive(:unknown?).and_return(false)
            render
            expect(rendered).to have_selector('input[type="submit"][value="Unknown"]:not([disabled="disabled"])')
          end
        end
      end
    end
  end

  describe 'response form' do
    it 'asks if logged in' do
      render
    end

    describe 'if not logged in' do
      it 'does not have a form' do
        render
        expect(rendered).not_to have_selector('form#new_rendered')
        expect(rendered).not_to have_selector("form[action='/predictions/6/rendereds']")
      end
    end

    describe '(logged in)' do
      before do
        allow(prediction).to receive(:unknown?).and_return(true)
        allow(prediction).to receive(:deadline).and_return 1.hour.from_now
        assign(:deadline_notification, DeadlineNotification.new(user: user, prediction: prediction))
        assign(:response_notification, ResponseNotification.new(user: user, prediction: prediction))
      end

      %i[response_notification deadline_notification].each do |form_name|
        describe 'check box for the notify user on overdue' do
          it "should have a form that submits to #{form_name}" do
            render
            expect(rendered).to have_selector("form[action='/#{form_name}s']")
          end

          it "should have a form with id new_#{form_name}" do
            render
            expect(rendered).to have_css("form#new_#{form_name}")
          end

          it "has a class of 'single-checkbox-form' on the form tag" do
            render
            expect(rendered).to have_css('form.single-checkbox-form')
          end

          it 'has a hidden field for prediction_id' do
            render
            expect(rendered).to have_selector("input[type='hidden'][name='#{form_name}[prediction_id]']", visible: false)
          end

          it 'has a submit button' do
            render
            expect(rendered).to have_css("form#new_#{form_name} input[type='submit']")
          end

          it 'has a enabled checkbox' do
            render
            expect(rendered).to have_checked_field("#{form_name}[enabled]")
          end
        end
      end
    end

    describe '(logged in)' do
      before do
        allow(prediction).to receive(:unknown?).and_return(true)
      end

      it 'has a form that submits to predictions/:id/responses' do
        allow(prediction).to receive(:to_param).and_return('6')
        render
        expect(rendered).to have_selector("form[action='/predictions/6/responses']")
      end

      it 'has a form with id new_response' do
        render
        expect(rendered).to have_css('form#new_response')
      end

      it 'has a textarea for comment' do
        render
        expect(rendered).to have_selector("textarea[name='response[comment]']")
      end

      it 'has a field for confidence' do
        render
        expect(rendered).to have_field('response[confidence]')
      end

      it 'does not show the confidence field if the prediction is not open' do
        allow(prediction).to receive(:open?).and_return(false)
        render
        expect(rendered).not_to have_field('response[confidence]')
      end

      it 'has a submit button' do
        render
        expect(rendered).to have_selector('form#new_response input[type="submit"]')
      end
    end
  end
end
