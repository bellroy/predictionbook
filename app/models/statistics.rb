class Statistics < BaseStatistics
  def initialize(wager_condition = nil)
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
    self
  end

  def each
    @intervals.keys.sort.each do |key|
      yield @intervals[key]
    end
    self
  end

  def headings
    collect(&:heading)
  end

  def sizes
    collect(&:count)
  end

  def size
    sizes.sum
  end

  def accuracies
    collect(&:accuracy)
  end

  def image_url
    # TODO: refactor (extract and such) and port to http://gchartrb.rubyforge.org/

    # http://code.google.com/apis/chart/#shape_markers
    # circle, red, first set, all points, 20px, on top of everything |
    blob = 'o,AAAAFF,0,-1,25,1'
    # horizontal line, color, ignored, start point, end point
    fifty_line = 'r,44FF44,0,0.49,0.51'
    # line, color, data set, size, priority
    joiner_line = 'D,FFCCCC,0,0,0.5,-1'
    markers = [blob, fifty_line, joiner_line].join('|')
    intervals = headings.join(',').delete('%')
    accuracies = self.accuracies.join(',')
    # Images api uses values 0..100 only
    sizes = self.sizes.join(',')
    image_size = '355x200'
    grid_lines = '20,20'
    # http://code.google.com/apis/chart/#multiple_axes_labels
    axis = 'x,x,y,y'
    # second axis, start at 50, go to 100
    axis_ranges = '0,50,100|1,0,100'
    # if we specify they are scaled for us
    data_ranges = "50,100,0,100,0,#{self.sizes.max}"
    axis_labels = '1:|Confidence  (%)|3:|Accuracy'
    axis_labels_positions = '1,50|3,50'

    'https://chart.apis.google.com/chart?' + [
      'cht=s', # scatterplot
      "chg=#{grid_lines}",
      "chds=#{data_ranges}",
      "chm=#{markers}",
      "chxt=#{axis}",
      "chxr=#{axis_ranges}",
      "chd=t:#{intervals}|#{accuracies}|#{sizes}",
      "chs=#{image_size}",
      "chxl=#{axis_labels}",
      "chxp=#{axis_labels_positions}"
    ].join('&')
  end

  def setup_intervals
    @intervals = {}
    [50, 60, 70, 80, 90, 100].each do |band|
      @intervals[band] = Interval.new(band)
    end
  end
end
