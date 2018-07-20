# frozen_string_literal: true

require 'spec_helper'

describe PredictionsController do
  let(:logged_in_user) { FactoryBot.create(:user) }
  let(:creator) { FactoryBot.create(:user) }
  let(:prediction) { FactoryBot.create(:prediction, creator: creator) }

  before { sign_in(logged_in_user) if logged_in_user.present? }

  describe 'getting the homepage' do
    before do
      relation = instance_double(ActiveRecord::Relation)
      allow(relation).to receive(:limit).and_return(relation)
      allow(relation).to receive(:includes).and_return(relation)
      expect(Prediction).to receive(:popular).and_return(relation)
    end

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
      relation = class_double(Prediction, page: :unjudged)
      expect(Prediction).to receive(:unjudged).and_return(relation)
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
      expect(Response).to receive(:recent).and_return(responses)
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
          relation = class_double(Prediction, page: @collection)
          expect(Prediction).to receive(:recent).and_return(relation)
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
    let(:params) { FactoryBot.build(:prediction).attributes }

    subject(:create) { post :create, params: { prediction: params } }

    describe 'privacy' do
      before do
        logged_in_user.update_attributes(visibility_default: Visibility::VALUES[:visible_to_creator])
      end

      describe 'when creator private default is true ' do
        context 'creating public prediction' do
          let(:params) { { visibility: 'visible_to_everyone' } }
          it 'is false when prediction privacy is false' do
            create
            expect(assigns[:prediction].visible_to_everyone?).to be true
          end
        end

        context 'when prediction privacy is true' do
          let(:params) { { visibility: 'visible_to_creator' } }

          specify do
            expect(Prediction).to receive(:create!)
              .with(hash_including('visibility' => 'visible_to_creator')).and_return(prediction)
            create
          end
        end

        context 'when prediction privacy is group' do
          let(:params) { { visibility: 'visible_to_group_345' } }

          specify do
            expect(Prediction).to receive(:create!)
              .with(hash_including('visibility' => 'visible_to_group', 'group_id' => 345))
              .and_return(prediction)
            create
          end
        end

        context 'when prediction privacy is not provided' do
          let(:params) { { visibility: logged_in_user.visibility_default } }

          it 'is true when prediction privacy is not provided' do
            expect(Prediction).to receive(:create!)
              .with(hash_including('visibility' => logged_in_user.visibility_default))
              .and_return(prediction)
            create
          end
        end
      end

      describe 'when creator private default is false' do
        before do
          logged_in_user.update_attributes(visibility_default: Visibility::VALUES[:visible_to_everyone])
        end

        context 'prediction privacy is false' do
          let(:params) { { visibility: :visible_to_everyone } }

          specify do
            expect(Prediction).to receive(:create!)
              .with(hash_including('visibility' => 'visible_to_everyone')).and_return(prediction)
            create
          end
        end

        context 'when prediction privacy is true' do
          let(:params) { { visibility: :visible_to_creator } }

          it 'is true when prediction privacy is true ' do
            expect(Prediction).to receive(:create!)
              .with(hash_including('visibility' => 'visible_to_creator')).and_return(prediction)
            create
          end
        end

        it 'is false when prediction privacy is not provided' do
          expect(Prediction).to receive(:create!)
            .with(hash_including('visibility' => 'visible_to_everyone'))
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

    subject(:show) { get :show, params: { id: prediction.id } }

    it 'assigns the prediction' do
      show
      expect(assigns[:prediction]).to eq prediction
    end

    it 'assigns the prediction events' do
      show
      expect(assigns[:events]).to eq prediction.events
    end

    describe 'response object for commenting or wagering' do
      before { expect(Prediction).to receive(:find).and_return prediction }

      it 'instantiates a new Response object' do
        expect(Response).to receive(:new)
        show
      end

      it 'assigns new wager object for the view' do
        expect(Response).to receive(:new).and_return :response
        show
        expect(assigns[:prediction_response]).to eq :response
      end

      it 'assigns the current user to the response' do
        expect(Response).to receive(:new).with(hash_including(user: logged_in_user))
        show
      end
    end

    it 'filters the deadline notifications by the current user' do
      show
      expect(response).to be_success
      expect(assigns[:deadline_notification]).to be_a DeadlineNotification
    end

    describe 'private predictions' do
      before(:each) do
        allow_any_instance_of(Prediction).to receive(:visible_to_everyone?).and_return(false)
        allow_any_instance_of(Prediction).to receive(:visible_to_creator?).and_return(true)
      end

      context 'not owned by current user' do
        let(:logged_in_user) { FactoryBot.create(:user) }
        it 'is forbidden when not owned by current user' do
          show
          expect(response.response_code).to eq 302
        end
      end

      context 'not logged in' do
        let(:logged_in_user) { nil }

        it 'is forbidden when not logged in' do
          show
          expect(response.response_code).to eq 302
        end
      end
    end

    describe 'response object for commenting or wagering' do
      it 'instantiates a new Response object' do
        show
        expect(assigns[:prediction_response]).to be_a Response
        expect(assigns[:prediction_response]).to be_new_record
        expect(assigns[:prediction_response].user).to eq logged_in_user
      end
    end
  end

  describe 'Updating the outcome of a prediction' do
    let(:id) { prediction.id }
    let(:outcome) { '' }

    subject(:judge) { post :judge, params: { id: id, outcome: outcome } }

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
    subject(:withdraw) { post :withdraw, params: { id: prediction.id } }

    describe 'when the current user is the creator of the prediction' do
      context 'not logged in' do
        let(:logged_in_user) { nil }

        it 'requires the user to be logged in' do
          withdraw
          expect(response).to redirect_to(new_user_session_path)
        end
      end

      context 'logged in' do
        before(:each) do
          expect(controller).to receive(:must_be_authorized_for_prediction)
        end

        it 'redirects to prediction page after POST to withdraw' do
          expect_any_instance_of(Prediction).to receive(:withdraw!)
          withdraw
          expect(response).to redirect_to(prediction_path(prediction.id))
        end
      end
    end

    describe 'when the current user is not the creator of the prediction' do
      it 'denies access' do
        allow_any_instance_of(Prediction).to receive(:private?).and_return(false)
        withdraw
        expect(response.response_code).to eq 302
      end
    end
  end

  %i[unjudged judged future].each do |action|
    describe action.to_s do
      let(:relation) { class_double(Prediction) }

      before :each do
        # touch to instantiate
        expect(Prediction).to receive(action).and_return(relation)
        expect(relation).to receive(:page).and_return(:collection)
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
    subject(:edit) { get :edit, params: { id: prediction.id } }

    describe 'not logged in' do
      let(:logged_in_user) { nil }
      it 'requires a login' do
        edit
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'when logged in' do
      it 'requires the user to have created the prediction' do
        edit
        expect(response.response_code).to eq 302
      end

      context 'logged in user is creator' do
        let(:creator) { logged_in_user }

        it 'assigns the prediction' do
          edit
          expect(assigns[:prediction]).to eq prediction
        end
      end
    end
  end

  describe 'updating a prediction' do
    subject(:update) do
      put :update, params: { id: prediction.id, prediction: { description: 'something' } }
    end

    context 'not logged in' do
      let(:logged_in_user) { nil }

      it 'requires a login' do
        update
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe 'when logged in' do
      it 'requires the user to have created the prediction' do
        update
        expect(response.response_code).to eq 302
      end

      context 'logged in user was the creator' do
        let(:logged_in_user) { creator }

        it 'updates the prediction' do
          update
          expect(prediction.reload.description).to eq 'something'
        end
      end
    end
  end
end
