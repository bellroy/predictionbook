class PredictionsQuery
  DEFAULT_PAGE = 1
  DEFAULT_PAGE_SIZE = 100
  MAXIMUM_PAGE_SIZE = 1000

  def initialize(user:, page: DEFAULT_PAGE, page_size: DEFAULT_PAGE_SIZE, tag_names: [])
    @page = page
    @page_size = page_size
    @tag_names = tag_names
    @user = user
  end

  def call
    filter_by_tags(initial_results)
      .includes(Prediction::DEFAULT_INCLUDES)
      .order(created_at: :desc)
      .page(page)
      .per(page_size)
  end

  private

  attr_reader :tag_names, :user

  def initial_results
    user.predictions.not_withdrawn
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
