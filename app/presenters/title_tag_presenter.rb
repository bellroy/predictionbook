class TitleTagPresenter
  def initialize(text)
    self.text = text
  end

  def tag
    RedCloth.new(html_encoded_text).to_html[3..-5]
  end

  private

  attr_accessor :text

  def html_encoded_text
    # encode tags, not entities
    HTMLEntities.new.encode(text.html_safe, :basic)
  end
end
