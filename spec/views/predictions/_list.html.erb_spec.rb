require 'spec_helper'

describe "prediction list" do

  before do
    assigns[:predictions] = []
    assigns[:statistics] = Statistics.new([])
    template.stub!(:show_statistics?).and_return(false)
    template.stub!(:current_user).and_return User.new
  end

  def render_view
    render :partial => 'predictions/list', :locals => { :title => 'Title' }
  end

  describe 'when showing statistics' do

    before(:each) do
      template.stub!(:show_statistics?).and_return(true)
      template.stub!(:global_statistics_cache_key).and_return("foo")
      template.stub!(:render).and_return("something to render")
    end

    it 'should render the statistics partial if show_statistics? is true' do
      template.stub!(:cache).and_yield
      template.should_receive(:render).with(:partial => 'statistics/show')
      render_view
    end

    it 'should cache the statistics partial' do
      lambda { render_view }.should cache_fragment("views/foo")
    end

    it "should use the global cache key for the partial" do
      template.should_receive(:global_statistics_cache_key)
      render_view
    end

  end

  describe "predictions" do

    describe "when logged in" do

      it "should show a message if there are no predictions" do
        render_view
        response.should have_tag('p', /No predictions to show; so\s+make your own!/)
      end

      it "should provide a link to make a new prediction if there are none" do
        render_view
        response.should have_tag('a[href=?]', '/predictions/new')
      end

    end

    describe "when not logged in" do
    
      before do
        template.stub!(:current_user).and_return nil
      end

      it "should show a message if there are no predictions" do
        render_view
        response.should have_tag('p', 'No predictions to show')
      end
    
    end

  end

end
