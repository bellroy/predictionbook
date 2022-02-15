class TagAdder
  def initialize(prediction:, string:)
    @prediction = prediction
    @string = string || ''
  end

  def call
    if string.present? && prediction.present?
      tag_names.each do |tag_name|
	      prediction.tag_names << tag_name
      end
    end

    tag_names.any?
  end

  def string_without_tags
    new_string = string.dup

    tag_names.each do |tag_name|
      new_string.gsub!("##{tag_name}", '')
    end

    new_string.strip.squeeze(' ')
  end

  def tag_names
    @tag_names ||= string.scan(HASH_TAG_REGEX).flatten.map do |name|
      name.tr('#', '')
    end
  end

  private

  HASH_TAG_REGEX = /#\w+/

  attr_reader :prediction, :string
end
