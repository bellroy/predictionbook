class Statistics < BaseStatistics
  def initialize(wager_condition=nil)
    setup_intervals
    # Sums up the total count and the accuracy into bands
    sql = <<-EOS
      SELECT
      ROUND(rel_conf - 5, -1) band,
      COUNT(*) sample_size,
      SUM(correct) / COUNT(*) accuracy
      FROM
      (SELECT
      CASE
        WHEN r.confidence >= 50 THEN r.confidence
        ELSE 100 - r.confidence
      END rel_conf,
      CASE
        WHEN (r.confidence >= 50 AND j.outcome = 1) OR
           (r.confidence < 50 AND j.outcome = 0) THEN 1
        ELSE 0
      END correct
      FROM responses r
      INNER JOIN predictions p ON r.prediction_id = p.id
      INNER JOIN (SELECT prediction_id, MAX(id) id
              FROM judgements
            GROUP BY prediction_id) mrj ON mrj.prediction_id = p.id
      INNER JOIN judgements j ON j.id = mrj.id
      WHERE r.confidence IS NOT NULL
      #{"AND #{wager_condition}" if wager_condition}) rc
      GROUP BY ROUND(rel_conf - 5, -1)
    EOS
    data = ActiveRecord::Base.connection.execute(sql)
    data.each do |datum|
      @intervals[datum[0]].update(datum)
    end
  end

  def setup_intervals
    @intervals = {}
    [50,60,70,80,90,100].each do |band|
      @intervals[band] = Interval.new(band)
    end
  end
end
