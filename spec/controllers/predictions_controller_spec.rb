# encoding: utf-8

require 'spec_helper'

describe PredictionsController do
  let(:logged_in_user) { FactoryGirl.create(:user) }
  let(:creator) { FactoryGirl.create(:user) }
  let(:prediction) { FactoryGirl.create(:prediction, creator: creator) }

  before { sign_in(logged_in_user) if logged_in_user.present? }

  describe 'getting the homepage' do
    it 'assigns a new prediction' do
      get :home
      expect(assigns[:prediction]).to be_a Prediction
      expect(assigns[:prediction]).to be_new_record
    end

    it 'assigns some responses' do
      get :home
      expect(assigns[:responses]).not_to be_nil
    end

    it 'returns http sucess status response' do
      get :home
      expect(response.response_code).to eq 200
    end
  end

  describe 'getting the "unjudged" page' do
    it 'assigns the unjudged predictions' do
      expect(Prediction).to receive(:unjudged).and_return(:unjudged)
      get :unjudged
      expect(assigns[:predictions]).to eq :unjudged
    end

    it 'responds with http success status' do
      get :unjudged
      expect(response.response_code).to eq 200
    end

    it 'renders index template' do
      get :unjudged
      expect(response).to render_template('predictions/index')
    end
  end

  describe 'getting the “happenstance” page' do
    it 'assigns predictions' do
      unjudged = double(:unjudged).as_null_object
      judged = double(:judged).as_null_object
      recent = double(:recent).as_null_object
      responses = double(:responses).as_null_object
      expect(Prediction).to receive(:unjudged).and_return(unjudged)
      expect(Prediction).to receive(:judged).and_return(judged)
      expect(Prediction).to receive(:recent).and_return(recent)
      expect(Response).to receive(:limit)
        .with(25).and_return(double(:collection, recent: responses))
      get :happenstance

      expect(assigns[:unjudged]).to eq unjudged
      expect(assigns[:judged]).to eq judged
      expect(assigns[:recent]).to eq recent
      expect(assigns[:responses]).to eq responses
    end
  end

  describe 'Getting a list of all predictions' do
    describe 'index of predictions' do
      it 'assigns recent predictions for the view' do
        recent = double(:recent_predictions).as_null_object
        expect(Prediction).to receive(:recent).and_return(recent)
        get :index
        expect(assigns[:predictions]).to eq recent
      end
    end

    describe 'statistics' do
      it 'provides a statistics accessor for the view' do
        expect(controller).to respond_to(:statistics)
      end

      it 'delegates statistics to the wagers collection' do
        stats = double(Statistics)
        expect(Statistics).to receive(:new).and_return(stats)
        expect(controller.statistics).to eq stats
      end
    end

    it 'responds with http success status' do
      get :index
      expect(response.response_code).to eq 200
    end

    it 'renders index template' do
      get :index
      expect(response).to render_template('predictions/index')
    end

    describe 'recent predictions index' do
      it 'renders' do
        get :index
        expect(response.response_code).to eq 200
      end

      it 'assigns the title' do
        get :index
        expect(assigns[:title]).not_to be_nil
      end

      describe 'collection' do
        before do
          @collection = []
          expect(Prediction).to receive(:recent).and_return(@collection)
        end

        it 'assigns the collection' do
          get :index
          expect(assigns[:predictions]).to eq @collection
        end
      end

      it 'assigns the filter' do
        get :index
        expect(assigns[:filter]).to eq 'recent'
      end
    end
  end

  describe 'Getting a form for a new Prediction' do
    context 'user logged in' do
      let(:logged_in_user) { nil }
      it 'redirects to the login page if not logged in' do
        get :new
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'user logged in' do
      it 'responds with http success status' do
        get :new
        expect(response).to be_success
      end

      it 'renders new template' do
        get :new
        expect(response).to render_template('predictions/new')
      end

      it 'instantiates a new Prediction object' do
        expect(Prediction).to receive(:new)
        get :new
      end

      it 'assigns new prediction object for the view' do
        expect(Prediction).to receive(:new).and_return(:prediction)
        get :new
        expect(assigns[:prediction]).to eq :prediction
      end
    end
  end

  describe 'Creating a new prediction' do
    let(:params) { FactoryGirl.build(:prediction).attributes }

    subject(:create) { post :create, prediction: params }

    describe 'privacy' do
      before do
        logged_in_user.update_attributes(private_default: true)
      end

      describe 'when creator private default is true ' do
        context 'creating public prediction' do
          let(:params) { { private: '0' } }
          it 'is false when prediction privacy is false' do
            create
            expect(assigns[:prediction].private?).to be false
          end
        end

        context 'when prediction privacy is true' do
          let(:params) { { private: prediction.id } }

          specify do
            expect(Prediction).to receive(:create!)
              .with(hash_including('private' => prediction.id.to_s)).and_return(prediction)
            create
          end
        end

        context 'when prediction privacy is not provided' do
          let(:params) { { private: logged_in_user.private_default } }

          it 'is true when prediction privacy is not provided' do
            expect(Prediction).to receive(:create!)
              .with(hash_including('private' => logged_in_user.private_default))
              .and_return(prediction)
            create
          end
        end
      end

      describe 'when creator private default is false' do
        before do
          logged_in_user.update_attributes(private_default: false)
        end

        context 'prediction privacy is false' do
          let(:params) { { private: '0' } }

          specify do
            expect(Prediction).to receive(:create!)
              .with(hash_including('private' => '0')).and_return(prediction)
            create
          end
        end

        context 'when prediction privacy is true' do
          let(:params) { { private: prediction.id } }

          it 'is true when prediction privacy is true ' do
            expect(Prediction).to receive(:create!)
              .with(hash_including('private' => prediction.id.to_s)).and_return(prediction)
            create
          end
        end

        it 'is false when prediction privacy is not provided' do
          expect(Prediction).to receive(:create!)
            .with(hash_including('private' => logged_in_user.private_default))
            .and_return(prediction)
          create
        end
      end
    end

    context 'not logged in' do
      let(:logged_in_user) { nil }
      it 'redirects to the login page if not logged in' do
        create
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    it 'uses the current_user as the creator' do
      expect(Prediction).to receive(:create!)
        .with(hash_including(creator_id: logged_in_user.id)).and_return(prediction)
      create
    end

    describe 'redirect' do
      it 'redirects to the prediction view page' do
        expect(Prediction).to receive(:create!).and_return(prediction)
        create

        expect(response).to redirect_to(prediction_path(prediction))
      end
      it 'goes to the index predictions view if there was a duplicate submit' do
        expect(Prediction).to receive(:create!)
          .and_raise(Prediction::DuplicateRecord.new(prediction))
        create

        expect(response).to redirect_to(prediction_path(prediction))
      end
    end

    it 'sets the Time.zone to users preference' do
      expect(Prediction).to receive(:create!).and_return(prediction)
      expect(controller).to receive(:set_timezone).at_least(:once)
      create
    end

    describe 'when the params are invalid' do
      before(:each) do
        expect(Prediction).to receive(:create!)
          .and_raise(ActiveRecord::RecordInvalid.new(prediction))
      end

      it 'responds with an http unprocesseable entity status' do
        create
        expect(response.response_code).to eq 422
      end

      it 'renders "new" form' do
        create
        expect(response).to render_template('predictions/new')
      end

      it 'assigns the prediction' do
        create
        expect(assigns[:prediction]).not_to be_nil
      end
    end
  end

  describe 'viewing a prediction' do
    let(:logged_in_user) { creator }

    it 'assigns the prediction' do
      get :show, id: prediction.id
      expect(assigns[:prediction]).to eq prediction
    end

    it 'assigns the prediction events' do
      get :show, id: prediction.id
      expect(assigns[:events]).to eq prediction.events
    end

    describe 'response object for commenting or wagering' do
      before { expect(Prediction).to receive(:find).and_return prediction }

      it 'instantiates a new Response object' do
        expect(Response).to receive(:new)
        get :show, id: prediction.id
      end

      it 'assigns new wager object for the view' do
        expect(Response).to receive(:new).and_return :response
        get :show, id: prediction.id
        expect(assigns[:prediction_response]).to eq :response
      end

      it 'assigns the current user to the response' do
        expect(Response).to receive(:new).with(hash_including(user: logged_in_user))
        get :show, id: prediction.id
      end
    end

    it 'filters the deadline notifications by the current user' do
      get :show, id: prediction.id
      expect(response).to be_success
      expect(assigns[:deadline_notification]).to be_a DeadlineNotification
    end

    describe 'private predictions' do
      before(:each) do
        allow_any_instance_of(Prediction).to receive(:private?).and_return(true)
      end

      context 'not owned by current user' do
        let(:logged_in_user) { FactoryGirl.create(:user) }
        it 'is forbidden when not owned by current user' do
          get :show, id: prediction.id
          expect(response.response_code).to eq 403
        end
      end

      context 'not logged in' do
        let(:logged_in_user) { nil }

        it 'is forbidden when not logged in' do
          get :show, id: prediction.id
          expect(response.response_code).to eq 403
        end
      end
    end

    describe 'response object for commenting or wagering' do
      it 'instantiates a new Response object' do
        get :show, id: prediction.id
        expect(assigns[:prediction_response]).to be_a Response
        expect(assigns[:prediction_response]).to be_new_record
        expect(assigns[:prediction_response].user).to eq logged_in_user
      end
    end
  end

  describe 'Updating the outcome of a prediction' do
    let(:id) { prediction.id }
    let(:outcome) { '' }

    subject(:judge) { post :judge, id: id, outcome: outcome }

    context 'not logged in' do
      let(:logged_in_user) { nil }

      it 'requires the user to be logged in' do
        judge
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context 'outcome is right' do
      let(:outcome) { 'right' }

      it 'sets the prediction to the passed outcome on POST to outcome' do
        allow_any_instance_of(Prediction).to receive(:judge!).with('right', anything)
        judge
      end
    end

    it 'passes in the user to the judge method' do
      allow_any_instance_of(Prediction).to receive(:judge!).with(anything, logged_in_user)
      judge
    end

    it 'finds and assign the prediction based on passed through ID' do
      allow_any_instance_of(Prediction).to receive(:judge!).with(anything, logged_in_user)
      judge
      expect(assigns[:prediction]).to eq prediction
    end

    it 'redirects to prediction page after POST to outcome' do
      allow_any_instance_of(Prediction).to receive(:judge!).with(anything, logged_in_user)
      judge
      expect(response).to redirect_to(prediction_path(prediction))
    end

    it 'sets a flash variable judged to a css class to apply to the judgment view' do
      allow_any_instance_of(Prediction).to receive(:judge!).with(anything, logged_in_user)
      judge
      expect(flash[:judged]).not_to be_nil
    end
  end

  describe 'Withdrawing a prediction' do
    describe 'when the current user is the creator of the prediction' do
      context 'not logged in' do
        let(:logged_in_user) { nil }

        it 'requires the user to be logged in' do
          post :withdraw, id: prediction.id
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      context 'logged in' do
        before(:each) do
          expect(controller).to receive(:must_be_authorized_for_prediction)
        end

        it 'redirects to prediction page after POST to withdraw' do
          expect_any_instance_of(Prediction).to receive(:withdraw!)
          post :withdraw, id: prediction.id
          expect(response).to redirect_to(prediction_path(prediction.id))
        end
      end
    end

    describe 'when the current user is not the creator of the prediction' do
      it 'denies access' do
        allow_any_instance_of(Prediction).to receive(:private?).and_return(false)
        post :withdraw, id: prediction.id
        expect(response.response_code).to eq 403
      end
    end
  end

  [:unjudged, :judged, :future].each do |action|
    describe action.to_s do
      before :each do
        # touch to instantiate
        controller
      end

      it 'renders' do
        get action
        expect(response.response_code).to eq 200
      end
      it 'assigns the title' do
        get action
        expect(assigns[:title]).not_to be_nil
      end
      it 'assigns the collection' do
        expect(Prediction).to receive(action).and_return(:collection)
        get action
        expect(assigns[:predictions]).to eq :collection
      end
      it 'assigns the filter' do
        get action
        expect(assigns[:filter]).to eq action.to_s
      end
    end
  end

  describe 'getting the edit form for a prediction' do
    describe 'not logged in' do
      let(:logged_in_user) { nil }
      it 'requires a login' do
        get :edit, id: prediction.id
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'when logged in' do
      it 'requires the user to have created the prediction' do
        get :edit, id: prediction.id
        expect(response.response_code).to eq 403
      end

      context 'logged in user is creator' do
        let(:creator) { logged_in_user }

        it 'assigns the prediction' do
          get :edit, id: prediction.id
          expect(assigns[:prediction]).to eq prediction
        end
      end
    end
  end

  describe 'updating a prediction' do
    context 'not logged in' do
      let(:logged_in_user) { nil }

      it 'requires a login' do
        put :update, id: prediction.id
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'when logged in' do
      it 'requires the user to have created the prediction' do
        put :update, id: prediction.id
        expect(response.response_code).to eq 403
      end

      context 'logged in user was the creator' do
        let(:logged_in_user) { creator }

        it 'updates the prediction' do
          put :update, id: prediction.id, prediction: { description: 'a new description' }
          expect(prediction.reload.description).to eq 'a new description'
        end
      end
    end
  end
end
