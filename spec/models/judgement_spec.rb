require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Judgement do
  it 'should have an associated user' do
    judgement = Judgement.new
    judgement.user.should == nil
    judgement.should respond_to(:user_id)
    judgement.should respond_to(:user=)
  end
  
  it 'should have an associated prediction' do
    judgement = Judgement.new
    judgement.prediction.should == nil
    judgement.should respond_to(:prediction)
    judgement.should respond_to(:prediction=)
  end
  
  describe '#outcome' do
    it 'should be true when assigned string “right”' do
      Judgement.new(:outcome => 'right').outcome.should == true
    end
    
    it 'should be false when assigned string “wrong”' do
      Judgement.new(:outcome => 'wrong').outcome.should == false
    end
    
    it 'should be nil when assigned string “unknown”' do
      Judgement.new(:outcome => 'unknown').outcome.should == nil
    end
    
    {"wrong" => false,"right" => true,"unknown" => nil}.each do |outcome,bool|
      it "should map #{outcome} string to boolean #{bool}" do 
        Judgement.new(:outcome => outcome).outcome.should == bool
      end
      it "should ignore cases for #{outcome.humanize} methods" do 
        Judgement.new(:outcome => outcome.humanize).outcome.should == bool
      end
    end
    
    [true, false, nil].each do |bool|
      it "should be true when assigned #{bool}" do
        Judgement.new(:outcome => bool).outcome.should == bool
      end
    end
  end
  
  describe '#outcome in words' do
    it 'should be "right" when outcome is true' do
      Judgement.new(:outcome => true).outcome_in_words.should =~ /^right/
    end
    it 'should be "wrong" when outcome is false' do
      Judgement.new(:outcome => false).outcome_in_words.should =~ /^wrong/
    end
    it 'should be "unknown" when outcome is nil' do
      Judgement.new(:outcome => nil).outcome_in_words.should =~ /^unknown/
    end
  end
end
