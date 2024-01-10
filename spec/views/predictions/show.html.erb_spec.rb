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
end
