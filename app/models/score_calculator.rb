class ScoreCalculator
  DECIMAL_PLACES = 2
  DEFAULT_SCORE = 1
  EPISILON = 0.005

  def initialize(prediction_scope, start_date: 1.day.from_now, interval: 1.month)
    self.prediction_scope = prediction_scope
    self.start_date = start_date
    self.interval = interval
    self.scores = {}
    generate_scores
  end

  def score
    scores.values.last
  end

  def time_series
    scores
  end

  private

  attr_accessor :prediction_scope, :start_date, :interval, :scores

  def generate_scores
    end_date = start_date
    while end_date < Time.zone.now || scores.empty?
      scores[end_date] = score_for_date(end_date)
      end_date += interval
    end
  end

  def score_for_date(end_date)
    sql = score_sql(end_date)
    sum, count = ActiveRecord::Base.connection.execute(sql).first
    if sum.blank?
      DEFAULT_SCORE
    else
      ((Math.log(0.5) * count) / sum).round(DECIMAL_PLACES)
    end
  end

  def score_sql(end_date)
    <<-EOS
      SELECT SUM(LOG(IF(j.outcome, (r.confidence / 100), (1 - (r.confidence / 100))))), COUNT(*)
      FROM responses r
      INNER JOIN predictions p ON p.id = r.prediction_id
      INNER JOIN (
        SELECT prediction_id, MAX(id) judgment_id FROM judgements GROUP BY prediction_id
      ) most_recent_judgements ON p.id = most_recent_judgements.prediction_id
      INNER JOIN judgements j ON most_recent_judgements.judgment_id = j.id
      WHERE #{prediction_scope_condition}
      AND r.confidence IS NOT NULL
      AND cast(r.created_at as date) <= '#{end_date.strftime('%Y-%m-%d')}'
      AND (p.withdrawn IS NULL OR p.withdrawn = 0)
    EOS
  end

  def prediction_scope_condition
    prediction_scope_id = prediction_scope.try(:id)
    if prediction_scope.is_a?(User)
      "r.user_id = #{prediction_scope_id}"
    elsif prediction_scope.is_a?(Group)
      group_visibility = Visibility::VALUES[:visible_to_group]
      "p.visibility = #{group_visibility} AND p.group_id = #{prediction_scope_id}"
    else
      '1 = 1'
    end
  end
end
