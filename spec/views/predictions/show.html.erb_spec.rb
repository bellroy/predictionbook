require 'spec_helper'

describe 'predictions/show.html.erb' do
  before(:each) do
    @user = create_valid_user(:name => 'person who created it', :login => "login.name")
    @prediction = create_valid_prediction(:creator=> @user)
    @prediction_response = valid_response(:prediction=> @prediction, :user=> @user)

    assign(:current_user, @user)
    assign(:prediction, @prediction)
    assign(:events, [])
    assign(:prediction_response, @prediction_response)
    assign(:deadline_notification, valid_deadline_notification)
    assign(:response_notification, valid_response_notification)
    view.stub(:current_user).and_return(@user)
    view.stub(:logged_in?).and_return(true)
  end

  it 'should have a heading of the predicitons description' do
    @prediction.stub(:description).and_return('Prediction Heading')
    render
    rendered.should have_css('h1', :text=> 'Prediction Heading')
  end

  describe 'creation time' do
    before(:each) do
      @time = 3.days.ago
      @prediction.stub(:created_at).and_return(@time)
      render
    end
    it 'should show when it was created' do
      rendered.should have_css('span', :text=> "3 days ago")
    end

    it 'should put the complete date in the title attribute of the span' do
      rendered.should have_selector("span[title='#{@time.to_s}']")
    end
  end

  describe 'prediction creator' do
    it 'should show who made the prediction' do
      render
      rendered.should have_css('.user', :text=> @user.name)
    end
  end

  describe 'outcome date' do
    before(:each) do
      @time = 10.days.from_now
      @prediction.stub(:deadline).and_return(@time)
      render
    end
    it 'should show when the outcome will be known' do
      rendered.should have_css('span', :text=> /10 days/)
    end
    it 'should put the complete date in the title attribute of the span' do
      rendered.should have_selector("span[title='#{@time.to_s}']")
    end
  end

  it 'should render the events partial' do
    render
    view.should render_template(:partial => 'predictions/_events')
  end

  describe 'confirming prediction outcome' do
    describe 'outcome form' do
      describe 'if not logged in' do
        it 'should not exist' do
          view.stub(:logged_in?).and_return(false)

          render
          rendered.should_not have_selector('form[action="/predictions/1/judge"]')
        end
      end

      describe 'if logged in but prediction is withdrawn' do
        it 'should not exist' do
          view.stub(:logged_in?).and_return(true)
          @prediction.stub(:withdrawn?).and_return(true)
          render
          rendered.should_not have_selector('form[action="/predictions/1/judge"]')
        end
      end

      describe 'if logged in' do
        before(:each) do
          view.stub(:logged_in?).and_return(true)
          @prediction.stub(:to_param).and_return('1')
        end
        describe 'form and submit tags' do
          before(:each) do
            render
          end
          it 'should have a form tag that submits to outcome' do
            rendered.should have_selector('form[method="post"][action="/predictions/1/judge"]')
          end

          it 'should have a right button' do
            rendered.should have_selector('input[type="submit"][name="outcome"][value="Right"]')
          end

          it 'should have a wrong button' do
            rendered.should have_selector('input[type="submit"][name="outcome"][value="Wrong"]')
          end

          it 'should have a unknown button' do
            rendered.should have_selector('input[type="submit"][name="outcome"][value="Unknown"]')
          end
        end
        describe 'button state' do
          it 'should disable the right button when the prediction is right' do
            @prediction.stub(:right?).and_return(true)
            render
            rendered.should have_selector('input[type="submit"][value="Right"][disabled="disabled"]')
          end
          it 'should not disable the right button when the prediction is not right' do
            @prediction.stub(:right?).and_return(false)
            render
            rendered.should have_selector('input[type="submit"][value="Right"]:not([disabled="disabled"])')
          end
          it 'should disable the wrong button when the prediction is wrong' do
            @prediction.stub(:wrong?).and_return(true)
            render
            rendered.should have_selector('input[type="submit"][value="Wrong"][disabled="disabled"]')
          end
          it 'should not disable the wrong button when the prediction is not wrong' do
            @prediction.stub(:wrong?).and_return(false)
            render
            rendered.should have_selector('input[type="submit"][value="Wrong"]:not([disabled="disabled"])')
          end
          it 'should disable the unknown button when the prediction is unknown' do
            @prediction.stub(:unknown?).and_return(true)
            render
            rendered.should have_selector('input[type="submit"][value="Unknown"][disabled="disabled"]')
          end
          it 'should not disable the unknown button when the prediction is known' do
            @prediction.stub(:unknown?).and_return(false)
            render
            rendered.should have_selector('input[type="submit"][value="Unknown"]:not([disabled="disabled"])')
          end
        end
      end
    end
  end

  describe 'response form' do
    it 'should ask if logged in' do
      view.should_receive(:logged_in?).at_least(:once).and_return(false)
      render
    end

    describe 'if not logged in' do
      it 'should not have a form' do
        view.stub(:logged_in?).and_return(false)

        render
        rendered.should_not have_selector('form#new_rendered')
        rendered.should_not have_selector("form[action='/predictions/6/rendereds']")
      end
    end


    describe '(logged in)' do
      before(:each) do
        @prediction.stub(:unknown?).and_return(true)
        view.stub(:logged_in?).and_return(true)
        @prediction.stub(:deadline).and_return 1.hour.from_now
        assign(:deadline_notification, DeadlineNotification.new(:user => @user, :prediction => @prediction))
        assign(:response_notification, ResponseNotification.new(:user => @user, :prediction => @prediction))
      end

      [:response_notification, :deadline_notification].each do |form_name|
        describe 'check box for the notify user on overdue' do
          it "should have a form that submits to #{form_name}" do
            render
            rendered.should have_selector("form[action='/#{form_name}s']")
          end

          it "should have a form with id new_#{form_name}" do
            render
            rendered.should have_css("form#new_#{form_name}")
          end

          it "should have a class of 'single-checkbox-form' on the form tag" do
            render
            rendered.should have_css("form.single-checkbox-form")
          end

          it 'should have a hidden field for prediction_id' do
            render
            rendered.should have_selector("input[type='hidden'][name='#{form_name}[prediction_id]']")
          end

          it 'should have a submit button' do
            render
            rendered.should have_css("form#new_#{form_name} input[type='submit']")
          end

          it 'should have a enabled checkbox' do
            render
            rendered.should have_checked_field("#{form_name}[enabled]")
          end
        end
      end
    end

    describe '(logged in)' do
      before(:each) do
        @prediction.stub(:unknown?).and_return(true)
        view.stub(:logged_in?).and_return(true)
      end

      it 'should have a form that submits to predictions/:id/responses' do
        @prediction.stub(:to_param).and_return('6')
        render
        rendered.should have_selector("form[action='/predictions/6/responses']")
      end

      it 'should have a form with id new_response' do
        render
        rendered.should have_css('form#new_response')
      end

      it 'should have a textarea for comment' do
        render
        rendered.should have_selector("textarea[name='response[comment]']")
      end

      it 'should have a field for confidence' do
        render
        rendered.should have_field('response[confidence]')
      end

      it 'should not show the confidence field if the prediction is not open' do
        @prediction.stub(:open?).and_return(false)
        render
        rendered.should_not have_field('response[confidence]')
      end

      it 'should have a submit button' do
        render
        rendered.should have_selector('form#new_response input[type="submit"]')
      end
    end
  end

end
