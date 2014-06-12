class Statistics
  include Enumerable
  
  def initialize(wagers)
    setup_intervals
    wagers = wagers.prefetch_joins if wagers.respond_to?(:prefetch_joins)
    wagers.each do |wager|
      interval_for(wager.relative_confidence).add(wager)
    end
    self
  end
  
  def each
    @intervals.keys.sort.each do |key|
      yield @intervals[key]
    end
    self
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
    intervals = collect(&:heading).join(",")
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
    title = 'How sure are you? Confidence vs. Accuracy (%)'
    axis_labels = "1:|Confidence  (%)|3:|Accuracy"
    axis_labels_positions = "1,50|3,50"
    
    "http://chart.apis.google.com/chart?" + [
      "cht=s", # scatterplot
      # "chtt=#{title}",
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
  
  def interval_for(percentage)
    @intervals[((percentage)/10)*10]
  end
  
  def setup_intervals
    @intervals = {100 => Interval.new("100",(100..100))}
    [50,60,70,80,90].each do |start|
      range = (start..start+9)
      @intervals[start] = Interval.new("#{start}",range)
    end
  end
  
  class Interval
    attr_reader :heading
    def initialize(heading,range)
      @heading = heading
      @range = range
      @wagers = []
    end
    def add(wager)
      @wagers.push(wager)
    end
    def count
      @wagers.reject {|w| w.unknown? }.size
    end
    def accuracy
      count > 0 ? (correct.to_f/count*100).round : 0
    end
    def correct
      @wagers.select {|w| w.correct? }.size
    end
  end
end
