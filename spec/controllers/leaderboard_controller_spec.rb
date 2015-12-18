require 'spec_helper'

describe LeaderboardController do
  describe 'getting the "leaderboard" page' do
    it 'should respond with http success status' do
      get :leaderboard
      response.response_code.should == 200
    end
    it 'should render the leaderboard template' do
      get :leaderboard
      response.should render_template('leaderboard/leaderboard')
    end
    it 'should find the list of users for the view' do
      users = mock(:users).as_null_object
      User.should_receive(:limit).with(100).and_return(mock(:collection, :sort_by=> users))
      get :leaderboard
      assigns[:users].should == users 
    end
    it 'should have users sorted in decreasing order of score' do
      users = [1.0, 4.3, 0.7, 1.9, 3.2, 3.0, 0.5, 1.1].map do |score|
        user = mock("user with score #{score}")
        user.stub(:statistics).and_return(mock(:statistics, :score => score))
        user.stub(:eligible_for_leaderboard?).and_return(true)
        user
      end
      User.should_receive(:limit).with(100).and_return(users)
      get :leaderboard
      assigns[:users].each do |user|
        user.statistics.score.should <= score if defined? score
        score = user.statistics.score
      end
    end
    it 'should only have users who have 10 or more judged wagers' do
      users = (0..20).map do |number_of_judged_responses|
        user = mock("user with #{number_of_judged_responses} judged responses")
        user.stub(:number_of_known_responses).and_return(number_of_judged_responses)
        user
      end
      get :leaderboard
      assigns[:users].each do |user|
        user.number_of_known_responses.should >= 10
      end
    end
  end
end
