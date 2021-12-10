class PredictionsQuery
  DEFAULT_PAGE = 1
  DEFAULT_PAGE_SIZE = 100
  MAXIMUM_PAGE_SIZE = 1000

  def initialize(creator:, page: DEFAULT_PAGE, page_size: DEFAULT_PAGE_SIZE, status: nil, tag_names: [])
    @page = page
    @page_size = page_size
    @status = status
    @tag_names = tag_names
    @creator = creator
  end

  def call
    FILTERS.reduce(initial_results) do |results, filter|
      apply_filter(results, filter)
    end.includes(Prediction::DEFAULT_INCLUDES).newest.page(page).per(page_size)
  end

  private

  FILTERS = [:status, :tags].freeze

  STATUSES = ['judged', 'unjudged', 'future']

  attr_reader :status, :tag_names, :creator

  def apply_filter(results, filter)
    send("filter_by_#{filter}", results)
  end

  def initial_results
    creator.predictions.not_withdrawn
  end

  def filter_by_status(results)
    if STATUSES.include?(status)
      results.public_send(status)
    else
      results
    end
  end

  def filter_by_tags(results)
    if tag_names.any?
      results.tagged_with(:names => tag_names, :match => :any)
    else
      results
    end
  end

  def page
    if @page.positive?
      @page
    else
      DEFAULT_PAGE
    end
  end
  
  def page_size
    if (1..MAXIMUM_PAGE_SIZE).cover?(@page_size)
      @page_size
    else
      DEFAULT_PAGE_SIZE
    end
  end
end
