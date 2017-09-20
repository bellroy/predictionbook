# frozen_string_literal: true

require 'spec_helper'

describe ResponsesController do
  let(:logged_in_user) { FactoryGirl.create(:user) }

  before(:each) do
    expect(controller).to receive(:set_timezone)
  end

  describe '#create' do
    let(:wager) { instance_double(Response, save: true) }
    let(:wagers) { instance_double(ActiveRecord::Relation, new: wager) }
    let(:prediction) do
      instance_double(Prediction, responses: wagers).as_null_object
    end
    let(:params) { { comment: 'A sample comment' } }

    subject(:create) { post :create, params: { prediction_id: '1', response: params } }

    it 'requires the user to be logged in' do
      create
      expect(response).to redirect_to(new_user_session_path)
    end

    context 'logged in' do
      before do
        sign_in logged_in_user
        expect(Prediction).to receive(:find).and_return(prediction)
      end

      it 'creates the response with the posted params and redirects' do
        expect(wagers).to receive(:new)
          .with(hash_including(comment: 'A sample comment', user_id: logged_in_user.id))
        create
        expect(response).to redirect_to(prediction_path(prediction))
      end

      describe 'when the params are invalid' do
        before(:each) do
          expect(wager).to receive(:save).and_return(false)
        end

        it 'responds with an http unprocesseable entity status' do
          create
          expect(response).to redirect_to(prediction_path(prediction))
          expect(flash[:error]).to eq 'You must enter an estimate or comment'
        end
      end
    end
  end

  describe '#preview' do
    before { sign_in logged_in_user }

    subject(:preview) { get :preview, params: { response: { comment: 'some text' } } }

    it 'responds to preview action and render partial' do
      mock_response = instance_double(Response).as_null_object
      expect(mock_response).not_to receive(:save!)
      expect(Response).to receive(:new).with('comment' => 'some text').and_return(mock_response)
      preview
      expect(response).to be_success
      expect(response).to render_template('responses/_preview')
    end
  end
end
