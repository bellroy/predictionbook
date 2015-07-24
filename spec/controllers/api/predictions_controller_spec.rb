# encoding: utf-8

require 'spec_helper'

describe Api::PredictionsController, type: :controller do
  before(:each) do
    controller.stub(:set_timezone)
  end

  describe 'index' do
    before(:each) do
      @prediction = build(:prediction)
      @predictions = [@prediction]
    end

    context 'with valid API token' do
      before(:each) do
        @user = build(:user_with_email)
        @user.stub(:api_token).and_return('token')
        User.stub(:find_by_api_token).and_return(@user)
        @recent = double(:recent_predictions)
        Prediction.should_receive(:limit)
          .with(100)
          .and_return(double(:collection, recent: @recent))
      end

      it 'should respond with HTTP success' do
        get :index, api_token: @user.api_token
        response.response_code == :success
      end

      it 'should respond with JSON content type' do
        get :index, api_token: @user.api_token
        response.content_type == Mime::JSON
      end

      it 'should respond with predictions' do
        get :index, api_token: @user.api_token
        response.body.should == @recent.to_json
      end
    end

    context 'with invalid API token' do
      before(:each) do
        User.stub(:find_by_api_token).and_return(nil)
      end

      it 'should respond with HTTP failure' do
        get :index
        response.response_code.should == 401
      end

      it 'should respond with JSON content type' do
        get :index
        response.content_type == Mime::JSON
      end
    end
  end

  describe 'create' do
    context 'with valid API token' do
      before(:each) do
        @user = build(:user_with_email)
        @user.stub(:api_token).and_return('token')
        User.stub(:find_by_api_token)
          .with(@user.api_token)
          .and_return(@user)
        @prediction = {
          description: 'The world will end tomorrow!',
          deadline: 1.day.ago,
          initial_confidence: '100'
        }
      end

      it 'should create a new prediction' do
        post :create, prediction: @prediction, api_token: @user.api_token
        response.body.should include(@prediction[:description])
      end

      context 'with a malformed prediction' do
        before(:each) do
          @prediction[:initial_confidence] = 9000
        end

        it 'should respond with HTTP failure' do
          post :create, prediction: @prediction, api_token: @user.api_token
          response.response_code.should == 422
        end

        it 'should respond with error messages' do
          post :create, prediction: @prediction, api_token: @user.api_token
          response.body.should include('a probability is between 0 and 100%')
        end
      end
    end

    context 'with invalid API token' do
      before(:each) do
        User.stub(:find_by_api_token).and_return(nil)
        @prediction = {
          description: 'The world will end tomorrow!',
          deadline: 1.day.ago,
          initial_confidence: '100'
        }
      end

      it 'should not create a new prediction' do
        post :create, prediction: @prediction
        response.body.should_not include(@prediction[:description])
      end

      it 'should respond with HTTP failure' do
        post :create, prediction: @prediction
        response.response_code.should == 401
      end
    end
  end
end
