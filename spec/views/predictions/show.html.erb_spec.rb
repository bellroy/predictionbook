require 'spec_helper'

describe 'Prediction detail page' do
  before(:each) do
    @user = assigns[:current_user] = User.new(:name => 'person who created it', :login => "login.name")
    assigns[:prediction] = @prediction = create_valid_prediction #mock_model(Prediction,
    @prediction.stub!(:creator).and_return(@user)
    @prediction_response = assigns[:prediction_response] = mock_model(Response, 
      :id => nil,
      :new_record? => true,
      :user => @user,
      :null_object => true,
      :errors => mock('errors', :on => nil)
       #HACK, mock_model#errors should expect this message!
       #TODO: extract this and possibly submit RSpec-Rails patch
    )
    template.stub!(:render).with(:partial => 'predictions/events')
  end
  
  it 'should have a heading of the predicitons description' do
    @prediction.stub!(:description).and_return('Prediction Heading')
    render_show
    response.should have_tag('h1', 'Prediction Heading')
  end
  
  describe 'creation time' do
    before(:each) do
      @time = 3.days.ago
      @prediction.stub!(:created_at).and_return(@time)
      render_show
    end
    it 'should show when it was created' do
      response.should have_tag('span', "3 days ago")
    end

    it 'should put the complete date in the title attribute of the span' do
      response.should have_tag('span[title=?]', @time.to_s)
    end
  end
  
  describe 'prediction creator' do
    it 'should show who made the prediction' do
      @prediction.stub!(:creator).and_return('Person')
      render_show
      response.should have_tag('[class=user]', 'Person')
    end
  end
      
  describe 'outcome date' do
    before(:each) do
      @time = 10.days.from_now
      @prediction.stub!(:deadline).and_return(@time)
      render_show
    end
    it 'should show when the outcome will be known' do
      response.should have_tag('span', /10 days/)
    end
    it 'should put the complete date in the title attribute of the span' do
      response.should have_tag('span[title=?]', @time.to_s)
    end
  end
  
  it 'should render the events partial' do
    template.should_receive(:render).with(:partial => 'predictions/events')
    render_show
  end
  
  describe 'confirming prediction outcome' do
    describe 'outcome form' do
      describe 'if not logged in' do
        it 'should not exist' do
          template.stub!(:logged_in?).and_return(false)

          render_show
          response.should_not have_tag('form[action="/predictions/1/judge"]')
        end
      end
      
      describe 'if logged in but prediction is withdrawn' do
        it 'should not exist' do
          template.stub!(:logged_in?).and_return(true)
          @prediction.stub!(:withdrawn?).and_return(true)
          render_show
          response.should_not have_tag('form[action="/predictions/1/judge"]')
        end
      end

      describe 'if logged in' do
        before(:each) do
          template.stub!(:logged_in?).and_return(true)
          @prediction.stub!(:to_param).and_return('1')
        end
        describe 'form and submit tags' do
          before(:each) do
            render_show
          end
          it 'should have a form tag that submits to outcome' do
            response.should have_tag('form[method="post"][action="/predictions/1/judge"]')
          end
      
          it 'should have a right button' do
            response.should have_tag('input[type="submit"][name="outcome"][value="Right"]')
          end
      
          it 'should have a wrong button' do
            response.should have_tag('input[type="submit"][name="outcome"][value="Wrong"]')
          end

          it 'should have a unknown button' do
            response.should have_tag('input[type="submit"][name="outcome"][value="Unknown"]')
          end
        end
        describe 'button state' do
          it 'should disable the right button when the prediction is right' do
            @prediction.stub!(:right?).and_return(true)
            render_show
            response.should have_tag('input[type="submit"][value="Right"][disabled="disabled"]')
          end
          it 'should not disable the right button when the prediction is not right' do
            @prediction.stub!(:right?).and_return(false)
            render_show
            response.should have_tag('input[type="submit"][value="Right"]:not([disabled="disabled"])')
          end
          it 'should disable the wrong button when the prediction is wrong' do
            @prediction.stub!(:wrong?).and_return(true)
            render_show
            response.should have_tag('input[type="submit"][value="Wrong"][disabled="disabled"]')
          end
          it 'should not disable the wrong button when the prediction is not wrong' do
            @prediction.stub!(:wrong?).and_return(false)
            render_show
            response.should have_tag('input[type="submit"][value="Wrong"]:not([disabled="disabled"])')
          end
          it 'should disable the unknown button when the prediction is unknown' do
            @prediction.stub!(:unknown?).and_return(true)
            render_show
            response.should have_tag('input[type="submit"][value="Unknown"][disabled="disabled"]')
          end
          it 'should not disable the unknown button when the prediction is known' do
            @prediction.stub!(:unknown?).and_return(false)
            render_show
            response.should have_tag('input[type="submit"][value="Unknown"]:not([disabled="disabled"])')
          end
        end
      end
    end
  end
  
  describe 'response form' do
    it 'should ask if logged in' do
      template.should_receive(:logged_in?).at_least(:once).and_return(false)
      render_show
    end
    
    describe 'if not logged in' do
      it 'should not have a form' do
        template.stub!(:logged_in?).and_return(false)
        
        render_show
        response.should_not have_tag('form#new_response')
        response.should_not have_tag('form[action=?]', '/predictions/6/responses')
      end
    end
    
    
    describe '(logged in)' do
      before(:each) do
        @prediction.stub!(:unknown?).and_return(true)
        template.stub!(:logged_in?).and_return(true)
        @prediction.stub!(:deadline).and_return 1.hour.from_now
        assigns[:deadline_notification] = DeadlineNotification.new(:user => @user, :prediction => @prediction)
        assigns[:response_notification] = ResponseNotification.new(:user => @user, :prediction => @prediction)
      end
      
      [:response_notification, :deadline_notification].each do |form_name|
        describe 'check box for the notify user on overdue' do
          it "should have a form that submits to #{form_name}" do
            render_show
            response.should have_tag('form[action=?]', "/#{form_name}s")
          end

          it "should have a form with id new_#{form_name}" do
            render_show
            response.should have_tag("form#new_#{form_name}")
          end
          
          it "should have a class of 'single-checkbox-form' on the form tag" do
            render_show
            response.should have_tag("form.single-checkbox-form")
          end

          it 'should have a hidden field for prediction_id' do
            render_show
            response.should have_tag('input[type="hidden"][name=?]', "#{form_name}[prediction_id]")
          end

          it 'should have a submit button' do
            render_show
            response.should have_tag("form#new_#{form_name} input[type=\"submit\"]")
          end

          it 'should have a enabled checkbox' do
            render_show
            response.should have_tag('input[type="checkbox"][name=?][checked=?]', "#{form_name}[enabled]", "checked")
          end
        end
      end
    end
    
    describe '(logged in)' do
      before(:each) do
        @prediction.stub!(:unknown?).and_return(true)
        template.stub!(:logged_in?).and_return(true)
      end

      it 'should have a form that submits to predictions/:id/responses' do
        @prediction.stub!(:to_param).and_return('6')
        render_show
        response.should have_tag('form[action=?]', '/predictions/6/responses')
      end
      
      it 'should have a form with id new_response' do
        render_show
        response.should have_tag('form#new_response')
      end
      
      it 'should have a textarea for comment' do
        render_show
        response.should have_tag('textarea[name=?]', 'response[comment]')
      end
  
      it 'should have a field for confidence' do
        render_show
        response.should have_tag('form input[name=?]','response[confidence]')
      end
  
      it 'should not show the confidence field if the prediction is not open' do
        @prediction.stub!(:open?).and_return(false)
        render_show
        response.should_not have_tag('form input[name=?]','response[confidence]')
      end
      
      it 'should have a submit button' do
        render_show
        response.should have_tag('form#new_response input[type="submit"]')
      end
    end
  end
  
  def render_show
    render 'predictions/show'
  end
end
