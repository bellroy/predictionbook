class ScoreCalculator
  DECIMAL_PLACES = 2
  DEFAULT_SCORE = 1
  EPISILON = 0.005

  def self.calculate(user)
    new(user).calculate
  end

  def initialize(user)
    self.user = user
  end

  def calculate
    score, count = score_and_count
    return DEFAULT_SCORE if score.nil? || score == 0.0
    ((Math.log(0.5) * count) / score).round(DECIMAL_PLACES)
  end

  private

  attr_accessor :user

  def score_and_count
    sql = <<-EOS
      SELECT SUM(LOG(IF(j.outcome, (r.confidence / 100), (1 - (r.confidence / 100))))), COUNT(*)
      FROM responses r
      INNER JOIN predictions p ON p.id = r.prediction_id
      INNER JOIN (
        SELECT prediction_id, MAX(id) judgment_id FROM judgements GROUP BY prediction_id
      ) most_recent_judgements ON p.id = most_recent_judgements.prediction_id
      INNER JOIN judgements j ON most_recent_judgements.judgment_id = j.id
      WHERE r.user_id = #{user.id}
      AND r.confidence IS NOT NULL
      AND (p.withdrawn IS NULL OR p.withdrawn = 0)
    EOS

    ActiveRecord::Base.connection.execute(sql).first
  end
end
