class BaseStatistics
  include Enumerable

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

    #TODO: refactor (extract and such) and port to http://gchartrb.rubyforge.org/

    # http://code.google.com/apis/chart/#shape_markers
    # circle, red, first set, all points, 20px, on top of everything |
    blob = 'o,AAAAFF,0,-1,25,1'
    # horizontal line, color, ignored, start point, end point
    fifty_line = 'r,44FF44,0,0.49,0.51'
    # line, color, data set, size, priority
    joiner_line = 'D,FFCCCC,0,0,0.5,-1'
    markers = [blob, fifty_line, joiner_line].join('|')
    intervals = self.headings.join(",").gsub("%", "")
    accuracies = self.accuracies.join(",")
    # Images api uses values 0..100 only
    sizes = self.sizes.join(',')
    image_size = "355x200"
    grid_lines = "20,20"
    # http://code.google.com/apis/chart/#multiple_axes_labels
    axis = 'x,x,y,y'
    # second axis, start at 50, go to 100
    axis_ranges = '0,50,100|1,0,100'
    # if we specify they are scaled for us
    data_ranges = "50,100,0,100,0,#{self.sizes.max}"
    axis_labels = "1:|Confidence  (%)|3:|Accuracy"
    axis_labels_positions = "1,50|3,50"

    "http://chart.apis.google.com/chart?" + [
      "cht=s", # scatterplot
      "chg=#{grid_lines}",
      "chds=#{data_ranges}",
      "chm=#{markers}",
      "chxt=#{axis}",
      "chxr=#{axis_ranges}",
      "chd=t:#{intervals}|#{accuracies}|#{sizes}",
      "chs=#{image_size}",
      "chxl=#{axis_labels}",
      "chxp=#{axis_labels_positions}",
    ].join('&')
  end

  class Interval
    attr_reader :heading, :count
    def initialize(band, count=0, acc=0)
      @heading = "#{band}%"
      @acc = acc
      @count = count
    end

    def update(row)
      @acc = row[2] || 0
      @count = row[1] || 0
    end

    def accuracy
      (@acc * 100).round.to_i
    end
  end
end
