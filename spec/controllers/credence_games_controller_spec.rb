require 'spec_helper'

describe CredenceGamesController do
  let(:user) { mock_model(User).as_null_object }

  before(:each) do
    controller.stub(:current_user).and_return(user)

    # Without this, the stub on CredenceGame throws an error the second time around.
    controller.stub(:set_timezone)
  end

  it 'should not error if the db has not been initialized' do
    expect { get :index }.not_to raise_error
  end

  describe 'Receiving a question' do
    let(:game) { valid_credence_game }

    before(:each) do
      CredenceQuestion.stub(:exists?).and_return(true)
      CredenceGame.stub(:find_or_create_by_user_id).and_return(game)
      game.stub(:current_response).and_return(:response)
    end

    it 'should index' do
      expect { get :index }.not_to raise_error
    end

    it 'should assign @game and @question' do
      get :index
      expect(assigns[:game]).to eq game
      expect(assigns[:question]).to eq :response
    end

    it 'should set @show_graph only for certain questions' do
      game.stub(:num_answered).and_return(10)
      get :index
      expect(assigns[:show_graph]).to eq false

      game.stub(:num_answered).and_return(20)
      get :index
      expect(assigns[:show_graph]).to eq true

      game.stub(:num_answered).and_return(25)
      get :index
      expect(assigns[:show_graph]).to eq false

      game.stub(:num_answered).and_return(30)
      get :index
      expect(assigns[:show_graph]).to eq true
    end
  end

  describe 'Answering a question' do
    def check_flash(correct)
      expect(flash[:correct]).to eq correct
      expect(flash[:score]).to eq (correct ? 3 : -3)
      expect(flash[:message]).to be_kind_of(String)
    end

    let(:game) { valid_credence_game }
    let(:question) { game.current_response }

    before(:each) do
      CredenceQuestion.stub(:exists?).and_return(true)
      CredenceGame.stub(:find_or_create_by_user_id).and_return(game)
      user.stub(:credence_game).and_return(game)

      game.stub(:new_question)
      game.stub(:save)
      question.stub(:save)

      # Can't set id in valid_credence_game_response ("can't mass-assign
      # protected attributes")
      question.stub(:id).and_return(1)
    end

    it 'should update' do
      expect(game).to receive(:new_question)
      expect(game).to receive(:save)
      expect(question).to receive(:save)

      post :update, :question_id => 1, :answer_index => 0, :credence => 51
    end

    it 'should not update when the question id is wrong' do
      expect(game).not_to receive(:new_question)
      expect(game).not_to receive(:save)
      expect(question).not_to receive(:save)

      CredenceGameResponse.stub(:find).and_return(question)
      question.stub(:given_answer).and_return(0)
      question.stub(:answer_credence).and_return(51)
      post :update, :question_id => 2, :answer_index => 0, :credence => 51

      check_flash(true)
    end

    it 'should set the flash correctly' do
      post :update, :question_id => 1, :answer_index => 0, :credence => 51
      check_flash(true)

      post :update, :question_id => 1, :answer_index => 1, :credence => 51
      check_flash(false)

      CredenceGameResponse.stub(:find).and_return(question)
      question.stub(:answer_credence).and_return(51)

      question.stub(:given_answer).and_return(0)

      post :update, :question_id => 2, :answer_index => 0, :credence => 70
      check_flash(true)

      post :update, :question_id => 2, :answer_index => 1, :credence => 70
      check_flash(true)

      question.stub(:given_answer).and_return(1)

      post :update, :question_id => 2, :answer_index => 0, :credence => 70
      check_flash(false)

      post :update, :question_id => 2, :answer_index => 1, :credence => 70
      check_flash(false)
    end

    it 'should give a helpful error for credences outside [1, 99]' do
      post :update, :question_id => 1, :answer_index => 0, :credence => 100
      expect(flash[:error]).not_to be_empty

      post :update, :question_id => 1, :answer_index => 0, :credence => 0
      expect(flash[:error]).not_to be_empty
    end
  end
end
