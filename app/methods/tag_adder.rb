class TagAdder
  def initialize(prediction:, save: true, string:)
    @prediction = prediction
    @save = save
    @string = string
  end

  def call
    if string.present? && prediction.present?
      tag_names.each do |tag_name|
	      prediction.tag_names << tag_name
      end && save && prediction.save
    end
  end

  def tag_names
    string.scan(HASH_TAG_REGEX).flatten.map { |name| name.tr('#', '') }
  end

  private

  HASH_TAG_REGEX = /#\w+/

  attr_reader :prediction, :save, :string
end
