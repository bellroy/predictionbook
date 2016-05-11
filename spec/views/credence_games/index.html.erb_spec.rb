require 'spec_helper'

describe 'credence_games/index' do
  describe 'without a game' do
    it 'should render without errors' do
      render
      expect(rendered).to_not be_blank
    end
  end

  describe 'with a game' do
    before do
      @game = valid_credence_game()

      # the form_tag() needs the game to have an id so it can generate the
      # URL. Should the URL even need the id? What happens if you edit the id?
      # And why doesn't setting the id in valid_credence_game work?
      @game.stub(:id).and_return(0)

      @question = valid_credence_game_response
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
