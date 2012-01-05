module PredictionHelper
  def outcome_button(outcome)
    submit_tag outcome,
      :title => outcome.to_s.humanize,
      :name => 'outcome',
      :disabled => @prediction.send("#{outcome.downcase}?")
  end
  
  def render_event_partial(event)
    dir_name = case event
    when Response then 'responses'
    when Judgement then 'judgements'
    when Prediction::Version then 'predictions/versions'
    end
    render :partial => "#{dir_name}/event", :locals => { :event => event }
  end
end
