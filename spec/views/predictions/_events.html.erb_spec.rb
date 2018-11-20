# frozen_string_literal: true

require 'spec_helper'

describe 'Prediction responses partial' do
  def render_partial
    render partial: 'predictions/events', events: @events 
  end

  before do
    user = mock_model(User).as_null_object
    @wager = mock_model(Response, created_at: Time.zone.now, user: user).as_null_object
    @events = [@wager]
  end

  it 'lists the responses' do
    @events = [@wager, @wager]
    render_partial
    expect(rendered).to have_selector('li', count: 2)
  end

  it 'shows the responses confidence' do
    expect(@wager).to receive(:confidence).and_return(30)
    render_partial
    expect(rendered).to match(/30%/)
  end

  it 'does not show nil relative_confidences' do
    expect(@wager).not_to receive(:relative_confidence)
    expect(@wager).to receive(:confidence).and_return(nil)
    render_partial
  end

  it 'shows who made the response' do
    expect(@wager).to receive(:user).and_return(User.new(name: 'Person', login: 'login.name'))
    render_partial
    expect(rendered).to have_css('.user', text: 'Person')
  end

  it 'shows when they made the response' do
    expect(@wager).to receive(:created_at).and_return(3.days.ago)
    render_partial
    expect(rendered).to have_css('span', text: '3 days ago')
  end

  describe 'includes any supplied comments' do
    before do
      expect(@wager).to receive(:comment?).and_return(true)
      expect(@wager).to receive(:comment).and_return(@comment = double('comment'))
      expect(@wager).to receive(:action_comment?).and_return(false)
    end

    it 'uses the markup helper to render any supplied comment' do
      expect(view).to receive(:markup).with(@comment).and_return('comment')
      render_partial
    end

    it 'includes the markup in the response' do
      expect(view).to receive(:markup).and_return('<comment>markup response</comment>')
      render_partial
      expect(rendered).to have_css('.comment', text: 'markup response')
    end
  end
end
