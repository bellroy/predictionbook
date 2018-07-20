require 'spec_helper'

describe 'credence_games/show' do
  describe 'without a game' do
    it 'should render without errors' do
      render
      expect(rendered).to_not be_blank
    end
  end

  describe 'with a game' do
    before do
      question = FactoryBot.create(:credence_question)
      FactoryBot.create_list(:credence_answer, 2, credence_question: question)
      @game = FactoryBot.create(:credence_game)
      @response = @game.current_response
    end

    it 'should render without errors' do
      render
      expect(rendered).to_not be_blank
    end

    it 'should have credence buttons' do
      render
      expect(rendered).to have_button('60%')
    end

    it 'should not show the graph with no questions answered' do
      render
      expect(rendered).to_not have_css('div#credence-graph')
    end

    it 'should be able to show the graph immediately' do
      @show_graph = true
      @game.num_answered = 1
      render
      expect(rendered).to have_css('div#credence-graph.show')
    end

    it 'should be able to not show the graph immediately' do
      @show_graph = false
      @game.num_answered = 1
      render
      expect(rendered).to have_css('div#credence-graph:not(.show)')
    end
  end
end
