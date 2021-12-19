class TagAdder
  def initialize(prediction:, string:)
    @prediction = prediction
    @string = string
  end

  def call
    if string.present? && prediction.present?
      tag_names.each do |tag_name|
	      prediction.tag_names << tag_name
      end && prediction.save
    end
  end

  def tag_names
    string.scan(HASH_TAG_REGEX).flatten.map { |name| name.tr('#', '') }
  end

  private

  HASH_TAG_REGEX = /#\w+/

  attr_reader :prediction, :string
end
