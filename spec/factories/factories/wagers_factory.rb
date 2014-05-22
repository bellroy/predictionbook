module WagersFactory
  def wager confidence, outcome
    response = Response.new({:confidence => confidence})
    response.stub!(:unknown?).and_return(outcome.nil?)
    if outcome.nil? || confidence >= 50
      response.stub!(:correct?).and_return(outcome)
    else
      # correct? needs to return the relative outcome (in other worrd, whether or not the outcame came out what the predictor
      # expected, while we take as input the absolute outcome.
      response.stub!(:correct?).and_return(!outcome)
    end
    response
  end
  
  def build_wagers wagers_list
      wagers = []
      wagers_list.each do |confidence, outcome|
        wagers.push wager confidence, outcome
      end
      wagers
  end
end
