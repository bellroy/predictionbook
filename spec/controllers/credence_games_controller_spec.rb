require 'spec_helper'

describe CredenceGamesController do
  before(:each) do
    # Without this, the stub on CredenceGame throws an error the second time around.
    controller.stub(:set_timezone)

    @user = mock_model(User).as_null_object
    controller.stub(:current_user).and_return(@user)
  end

  it 'should not error if the db has not been initialized' do
    get :index
  end

  describe 'with an existing game' do
    before(:each) do
      CredenceQuestion.stub(:exists?).and_return(true)
      @game = valid_credence_game
      CredenceGame.stub(:find_or_create_by_user_id).and_return(@game)
      @game.stub(:current_response).and_return(:response)
    end

    it 'should index' do
      get :index
    end

    it 'should assign @game and @question' do
      get :index
      assigns[:game].should == @game
      assigns[:question].should == :response
    end

    it 'should set @show_graph only for certain questions' do
      @game.stub(:num_answered).and_return(10)
      get :index
      assigns[:show_graph].should == false

      @game.stub(:num_answered).and_return(20)
      get :index
      assigns[:show_graph].should == true

      @game.stub(:num_answered).and_return(25)
      get :index
      assigns[:show_graph].should == false

      @game.stub(:num_answered).and_return(30)
      get :index
      assigns[:show_graph].should == true
    end
  end
end
