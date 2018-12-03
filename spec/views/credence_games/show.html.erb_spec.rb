# frozen_string_literal: true

require 'spec_helper'

describe 'credence_games/show' do
  describe 'without a game' do
    it 'renders without errors' do
      render
      expect(rendered).not_to be_blank
    end
  end

  describe 'with a game' do
    before do
      question = FactoryBot.create(:credence_question)
      FactoryBot.create_list(:credence_answer, 2, credence_question: question)
      @game = FactoryBot.create(:credence_game)
      @response = @game.current_response
    end

    it 'renders without errors' do
      render
      expect(rendered).not_to be_blank
    end

    it 'has credence buttons' do
      render
      expect(rendered).to have_button('60%')
    end

    it 'does not show the graph with no questions answered' do
      render
      expect(rendered).not_to have_css('div#credence-graph')
    end

    it 'is able to show the graph immediately' do
      @show_graph = true
      @game.num_answered = 1
      render
      expect(rendered).to have_css('div#credence-graph.show')
    end

    it 'is able to not show the graph immediately' do
      @show_graph = false
      @game.num_answered = 1
      render
      expect(rendered).to have_css('div#credence-graph:not(.show)')
    end
  end
end
