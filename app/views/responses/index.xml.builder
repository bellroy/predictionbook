xml.instruct! :xml, :version => "1.0" 
xml.rss(:version => "2.0") do
  xml.channel do
    xml.title "Recent Responses"
    xml.description "List of #{@responses.size} most recent"
    xml.link "http://predictionbook.com/responses"
    xml.language "en-us"
    
    @responses.each do |response|
      xml.item do
        xml.title "#{response.user} on “#{ response.prediction.description }”"
        xml.description render( :partial => 'responses/response', :locals => {:response => response})
        xml.pubDate response.created_at.to_s(:rfc822)
        xml.guid "response_#{response.id}", :isPermaLink => false
      end
    end
  end
end