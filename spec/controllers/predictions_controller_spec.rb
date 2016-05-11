# encoding: utf-8

require 'spec_helper'

describe PredictionsController do
  describe 'getting the homepage' do
    it 'assigns a new prediction' do
      Prediction.stub(:new).and_return(:new_prediction)
      get :home
      expect(assigns[:prediction]).to eq :new_prediction
    end

    it 'assigns some responses' do
      Response.stub(:limit).and_return(double('responses', recent: :responses))
      get :home
      expect(assigns[:responses]).to eq :responses
    end

    it 'returns http sucess status response' do
      get :home
      expect(response.response_code).to eq 200
    end
  end

  describe 'getting the "unjudged" page' do
    it 'assigns the unjudged predictions' do
      Prediction.should_receive(:unjudged).and_return(:unjudged)
      get :unjudged
      expect(assigns[:predictions]).to eq :unjudged
    end

    it 'responds with http success status' do
      get :unjudged
      expect(response.response_code).to eq 200
    end

    it 'renders index template' do
      get :unjudged
      response.should render_template('predictions/index')
    end
  end

  describe 'getting the “happenstance” page' do
    it 'assigns predictions' do
      unjudged = double(:unjudged).as_null_object
      judged = double(:judged).as_null_object
      recent = double(:recent).as_null_object
      responses = double(:responses).as_null_object
      Prediction.should_receive(:limit).with(5).and_return(double(:collection, unjudged: unjudged))
      Prediction.should_receive(:limit).with(5).and_return(double(:collection, judged: judged))
      Prediction.should_receive(:limit).with(5).and_return(double(:collection, recent: recent))
      Response.should_receive(:limit).with(25).and_return(double(:collection, recent: responses))
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
        Prediction.should_receive(:limit).with(100).and_return(double(:collection, recent: recent))
        get :index
        expect(assigns[:predictions]).to eq recent
      end
    end

    describe 'statistics' do
      it 'provides a statistics accessor for the view' do
        controller.should respond_to(:statistics)
      end

      it 'delegates statistics to the wagers collection' do
        stats = double(Statistics)
        Statistics.stub(:new).and_return(stats)
        expect(controller.statistics).to eq stats
      end
    end

    it 'responds with http success status' do
      get :index
      expect(response.response_code).to eq 200
    end

    it 'renders index template' do
      get :index
      response.should render_template('predictions/index')
    end

    describe 'recent predictions index' do
      it 'renders' do
        get :index
        expect(response.response_code).to eq 200
      end

      it 'assigns the title' do
        get :index
        assigns[:title].should_not be_nil
      end

      describe 'collection' do
        before do
          @collection = []
          Prediction.stub(:recent).and_return(@collection)
        end

        it 'assigns the collection' do
          @collection.stub(:prefetch_joins).and_return(@collection)
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
    it 'redirects to the login page if not logged in' do
      get :new
      response.should redirect_to(new_user_session_path)
    end

    context 'user logged in' do
      before { sign_in FactoryGirl.create(:user) }

      it 'responds with http success status' do
        get :new
        response.should be_success
      end

      it 'renders new template' do
        get :new
        response.should render_template('predictions/new')
      end

      it 'instantiates a new Prediction object' do
        Prediction.should_receive(:new)
        get :new
      end

      it 'assigns new prediction object for the view' do
        Prediction.stub(:new).and_return(:prediction)
        get :new
        expect(assigns[:prediction]).to eq :prediction
      end
    end
  end

  describe 'Creating a new prediction' do
    def post_prediction(params = {})
      post :create, 'prediction' => params
    end

    before(:each) do
      @prediction = FactoryGirl.create(:prediction)
      Prediction.stub(:create!)
      Prediction.stub(:recent)
      controller.stub(:logged_in?).and_return(true)
      @user = build(:user)
      controller.stub(:current_user).and_return(@user)
    end

    describe 'privacy' do
      before do
        @user.private_default = true
        Prediction.stub(:create!).and_return(@prediction)
      end

      describe 'when creator private default is true ' do
        it 'is false when prediction privacy is false' do
          Prediction.should_receive(:create!).with(hash_including('private' => '0'))
          post_prediction('private' => '0')
        end

        it 'is true when prediction privacy is true ' do
          Prediction.should_receive(:create!).with(hash_including('private' => '1'))
          post_prediction('private' => '1')
        end

        it 'is true when prediction privacy is not provided' do
          Prediction.should_receive(:create!).with(hash_including('private' => @user.private_default))
          post_prediction
        end
      end

      describe 'when creator private default is false' do
        before do
          @user.private_default = false
        end

        it 'is false when prediction privacy is false' do
          Prediction.should_receive(:create!).with(hash_including('private' => '0'))
          post_prediction('private' => '0')
        end

        it 'is true when prediction privacy is true ' do
          Prediction.should_receive(:create!).with(hash_including('private' => '1'))
          post_prediction('private' => '1')
        end

        it 'is false when prediction privacy is not provided' do
          Prediction.should_receive(:create!).with(hash_including('private' => @user.private_default))
          post_prediction
        end
      end
    end

    it 'redirects to the login page if not logged in' do
      controller.stub(:logged_in?).and_return(false)
      post_prediction
      response.should redirect_to(new_user_session_path)
    end

    it 'uses the current_user as the creator' do
      u = mock_model(User)
      controller.stub(:current_user).and_return(u)
      Prediction.should_receive(:create!).with(hash_including(creator: u)).and_return(@prediction)
      post_prediction
    end

    it 'creates a new prediction with the POSTed params' do
      Prediction.should_receive(:create!).with(hash_including(description: 'foobar')).and_return(@prediction)
      post_prediction(description: 'foobar')
    end

    describe 'redirect' do
      it 'redirects to the prediction view page' do
        Prediction.stub(:create!).and_return(@prediction)
        post_prediction

        response.should redirect_to(prediction_path(@prediction))
      end
      it 'goes to the index predictions view if there was a duplicate submit' do
        Prediction.stub(:create!).and_raise(Prediction::DuplicateRecord.new(@prediction))
        post_prediction

        response.should redirect_to(prediction_path(@prediction))
      end
    end

    it 'sets the Time.zone to users preference' do
      Prediction.stub(:create!).and_return(@prediction)
      controller.should_receive(:set_timezone).at_least(:once) # before filters suck in spec-land
      post_prediction
    end

    describe 'when the params are invalid' do
      before(:each) do
        prediction = mock_model(Prediction, errors: double('errors', full_messages: []))
        Prediction.stub(:create!).and_raise(ActiveRecord::RecordInvalid.new(prediction))
      end

      it 'responds with an http unprocesseable entity status' do
        post_prediction
        expect(response.response_code).to eq 422
      end

      it 'renders "new" form' do
        post_prediction
        response.should render_template('predictions/new')
      end

      it 'assigns the prediction' do
        post_prediction
        assigns[:prediction].should_not be_nil
      end
    end
  end

  describe 'viewing a prediction' do
    before do
      @prediction = FactoryGirl.create(:prediction)
      Prediction.stub(:find).and_return(@prediction)
      controller.stub(:logged_in?).and_return(true)
      controller.stub(:current_user).and_return(mock_model(User))
    end

    it 'assigns the prediction to prediction' do
      get :show, id: '1'
      expect(assigns[:prediction]).to eq @prediction
    end

    # TODO: Make blackbox (will probably have to hit DB)
    it 'gets the deadline notifications for the prediction' do
      dn = @prediction.deadline_notifications
      @prediction.should_receive(:deadline_notifications).at_least(:once).and_return(dn)
      get :show, id: '1'
    end

    # TODO: too long
    it 'filters the deadline notifications by the current user' do
      u = User.new
      controller.stub(:current_user).and_return(u)
      @prediction.deadline_notifications.should_receive(:find_by_user_id).with(u).and_return(:a_dn)
      get :show, id: '1'

      expect(assigns[:deadline_notification]).to eq :a_dn
    end

    it 'finds the prediction based on id' do
      Prediction.should_receive(:find).with('5').and_return(@prediction)
      get :show, id: '5'
    end

    describe 'private predictions' do
      before(:each) do
        @prediction.stub(:private?).and_return(true)
        @prediction.stub(:creator).and_return(@user = User.new)
      end

      it 'is forbidden when not owned by current user' do
        controller.stub(:current_user).and_return(User.new)
        get :show, id: '1'
        expect(response.response_code).to eq 403
      end

      it 'is forbidden when not logged in' do
        controller.stub(:current_user).and_return(nil)
        controller.stub(:logged_in?).and_return(false)
        get :show, id: '1'
        expect(response.response_code).to eq 403
      end

      it 'is viewable when user is current user' do
        controller.stub(:current_user).and_return(@user)
        get :show, id: '1'
        response.should be_success
      end
    end

    describe 'response object for commenting or wagering' do
      before(:each) do
        Prediction.stub(:find).and_return FactoryGirl.create(:prediction)
      end

      it 'instantiates a new Response object' do
        Response.should_receive(:new)
        get :show, id: '6'
      end

      it 'assigns new wager object for the view' do
        Response.stub(:new).and_return :response
        get :show, id: '6'
        expect(assigns[:prediction_response]).to eq :response
      end

      it 'assigns the current user to the response' do
        user = User.new
        controller.stub(:current_user).and_return(user)
        Response.should_receive(:new).with(hash_including(user: user))
        get :show, id: '6'
      end
    end
  end

  describe 'Updating the outcome of a prediction' do
    before(:each) do
      @prediction = mock_model(Prediction, to_param: '1') # .as_null_object
      Prediction.stub(:find).and_return(@prediction)
      controller.stub(:logged_in?).and_return(true)
      controller.stub(:current_user)
    end

    def post_outcome(params = {})
      post :judge, { id: '1', outcome: '' }.merge(params)
    end

    it 'requires the user to be logged in' do
      controller.stub(:logged_in?).and_return(false)
      post_outcome
      response.should redirect_to(new_user_session_path)
    end

    it 'sets the prediction to the passed outcome on POST to outcome' do
      @prediction.should_receive(:judge!).with('right', anything)
      post_outcome outcome: 'right'
    end

    it 'passes in the user to the judge method' do
      controller.stub(:current_user).and_return(:mr_user)
      @prediction.should_receive(:judge!).with(anything, :mr_user)
      post_outcome
    end

    it 'finds and assign the prediction based on passed through ID' do
      Prediction.should_receive(:find).with('444').and_return(@prediction)
      @prediction.should_receive(:judge!).with(anything, nil)
      post_outcome id: '444'
      expect(assigns[:prediction]).to eq @prediction
    end

    it 'redirects to prediction page after POST to outcome' do
      @prediction.stub(:to_param).and_return('33')
      @prediction.should_receive(:judge!).with(anything, nil)
      post_outcome id: '33'
      response.should redirect_to(prediction_path('33'))
    end

    it 'sets a flash variable judged to a css class to apply to the judgment view' do
      @prediction.should_receive(:judge!).with(anything, nil)
      post_outcome
      flash[:judged].should_not be_nil
    end

    describe 'expiring the cached statistics fragments for users' do
      before(:each) do
        User.destroy_all
        @prediction = FactoryGirl.create(:prediction)
        Prediction.stub(:find).and_return(@prediction)
        @prediction.stub(:to_param).and_return('zippy')
      end

      it 'expires fragment for the creator of the prediction' do
        -> { post_outcome }.should expire_fragment("views/statistics_partial-#{@prediction.creator.to_param}")
      end
      it 'expires fragment for other users that have wagered on the prediction' do
        @prediction.responses.create!(user: valid_user(login: 'mr-meeto'), confidence: '90')
        -> { post_outcome }.should expire_fragment('views/statistics_partial-mr-meeto')
      end
      it "does not expire fragment for other users that haven't wagered on the prediction" do
        @prediction.stub(:wagers).and_return([])
        -> { post_outcome }.should_not expire_fragment('views/statistics_partial-not-mee')
      end
      it 'expires to application-wide statistics partial' do
        -> { post_outcome }.should expire_fragment('views/statistics_partial')
      end
    end
  end

  describe 'Withdrawing a prediction' do
    before(:each) do
      @prediction = mock_model(Prediction, id: '12') # .as_null_object
      Prediction.stub(:find).and_return(@prediction)
      controller.stub(:logged_in?).and_return(true)
    end

    describe 'when the current user is the creator of the prediction' do
      before(:each) do
        controller.stub(:must_be_authorized_for_prediction)
      end

      it 'requires the user to be logged in' do
        controller.stub(:logged_in?).and_return(false)
        post :withdraw, id: '12'
        response.should redirect_to(new_user_session_path)
      end

      it 'redirects to prediction page after POST to withdraw' do
        @prediction.should_receive(:withdraw!)
        post :withdraw, id: '12'
        response.should redirect_to(prediction_path('12'))
      end

      it 'calls the withdraw! method on the prediction' do
        @prediction.should_receive(:withdraw!)
        post :withdraw, id: '12'
      end
    end
    describe 'when the current user is not the creator of the prediction' do
      it 'denies access' do
        @prediction.stub(:creator).and_return(User.new)
        @prediction.should_receive(:private?).and_return(false)
        controller.stub(:current_user).and_return(User.new)
        post :withdraw, id: '12'
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
        assigns[:title].should_not be_nil
      end
      it 'assigns the collection' do
        Prediction.stub(action).and_return(:collection)
        get action
        expect(assigns[:predictions]).to eq :collection
      end
      it 'assigns the filter' do
        get action
        expect(assigns[:filter]).to eq action.to_s
      end
    end
  end

  describe 'viewing a prediction' do
    before do
      @prediction = FactoryGirl.create(:prediction)
      Prediction.stub(:find).and_return(@prediction)
      controller.stub(:logged_in?).and_return(true)
      controller.stub(:current_user).and_return(mock_model(User))
    end

    it 'assigns the prediction to @prediction' do
      get :show, id: '1'
      expect(assigns[:prediction]).to eq @prediction
    end

    it 'assigns the prediction events to @events' do
      get :show, id: '1'
      expect(assigns[:events]).to eq @prediction.events
    end

    # TODO: Make blackbox (will probably have to hit DB)
    it 'gets the deadline notifications for the prediction' do
      dn = @prediction.deadline_notifications
      @prediction.should_receive(:deadline_notifications).at_least(:once).and_return(dn)
      get :show, id: '1'
    end

    # TODO: too long
    it 'filters the deadline notifications by the current user' do
      u = User.new
      controller.stub(:current_user).and_return(u)
      @prediction.deadline_notifications.should_receive(:find_by_user_id).with(u).and_return(:a_dn)
      get :show, id: '1'

      expect(assigns[:deadline_notification]).to eq :a_dn
    end

    it 'finds the prediction based on id' do
      Prediction.should_receive(:find).with('5').and_return(@prediction)
      get :show, id: '5'
    end

    describe 'private predictions' do
      before(:each) do
        @prediction.stub(:private?).and_return(true)
        @prediction.stub(:creator).and_return(@user = User.new)
      end

      it 'is forbidden when not owned by current user' do
        controller.stub(:current_user).and_return(User.new)
        get :show, id: '1'
        expect(response.response_code).to eq 403
      end

      it 'is forbidden when not logged in' do
        controller.stub(:current_user).and_return(nil)
        controller.stub(:logged_in?).and_return(false)
        get :show, id: '1'
        expect(response.response_code).to eq 403
      end

      it 'is viewable when user is current user' do
        controller.stub(:current_user).and_return(@user)
        get :show, id: '1'
        response.should be_success
      end
    end

    describe 'response object for commenting or wagering' do
      before(:each) do
        Prediction.stub(:find).and_return FactoryGirl.create(:prediction)
      end

      it 'instantiates a new Response object' do
        Response.should_receive(:new)
        get :show, id: '6'
      end

      it 'assigns new wager object for the view' do
        Response.stub(:new).and_return :response
        get :show, id: '6'
        expect(assigns[:prediction_response]).to eq :response
      end

      it 'assigns the current user to the response' do
        user = User.new
        controller.stub(:current_user).and_return(user)
        Response.should_receive(:new).with(hash_including(user: user))
        get :show, id: '6'
      end
    end
  end

  describe 'getting the edit form for a prediction' do
    it 'requires a login' do
      get :edit, id: '1'
      response.should redirect_to(new_user_session_path)
    end

    describe 'when logged in' do
      before(:each) do
        controller.stub(:login_required)
        @p = FactoryGirl.create(:prediction)
      end

      it 'requires the user to have created the prediction' do
        controller.stub(:current_user).and_return(User.new)
        get :edit, id: @p.id
        expect(response.response_code).to eq 403
      end

      it 'assigns the prediction' do
        controller.stub(:current_user).and_return(@p.creator)
        get :edit, id: @p.id
        expect(assigns[:prediction]).to eq @p
      end
    end
  end

  describe 'updating a prediction' do
    it 'requires a login' do
      put :update, id: '1'
      response.should redirect_to(new_user_session_path)
    end

    describe 'when logged in' do
      before(:each) do
        controller.stub(:login_required)
        @p = FactoryGirl.create(:prediction)
      end

      it 'requires the user to have created the prediction' do
        controller.stub(:current_user).and_return(User.new)
        put :update, id: @p.id
        expect(response.response_code).to eq 403
      end

      it 'updates the prediction' do
        Prediction.stub(:find).and_return(@p)
        @p.should_receive(:update_attributes!).with('prediction_params')
        controller.stub(:must_be_authorized_for_prediction)
        put :update, id: @p.id, prediction: :prediction_params
      end
    end
  end
end
