# frozen_string_literal: true

require 'spec_helper'

describe 'prediction list' do
  before do
    assign(:predictions, double(Prediction, current_page: 1, limit_value: 1, total_pages: 1,
                                            empty?: true))
    assign(:statistics, Statistics.new)
    assign(:show_statistics, false)
    allow(view).to receive(:current_user).and_return User.new
  end

  def render_view
    render 'predictions/list', title: 'Title' 
  end

  describe 'when showing statistics' do
    before do
      assign(:show_statistics, true)
      expect(view).to receive(:global_statistics_cache_key).and_return('foo')
    end

    it 'renders the statistics partial if show_statistics? is true' do
      expect(view).to receive(:cache).and_yield
      render_view
      expect(view).to render_template(partial: 'statistics/_show')
    end
  end

  describe 'predictions' do
    describe 'when logged in' do
      it 'shows a message if there are no predictions' do
        render_view
        expect(rendered).to have_css('p', text: /No predictions to show; so\s+make your own!/)
      end

      it 'provides a link to make a new prediction if there are none' do
        render_view
        expect(rendered).to have_selector("a[href='/predictions/new']")
      end
    end

    describe 'when not logged in' do
      before do
        expect(view).to receive(:current_user).and_return nil
      end

      it 'shows a message if there are no predictions' do
        render_view
        expect(rendered).to have_css('p', text: 'No predictions to show')
      end
    end
  end
end
