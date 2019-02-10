if response.confidence?
  xml << render(partial: 'responses/wager', wager: response)
end
xml.br if response.confidence? and response.comment?
if response.comment? 
  xml << render(partial: 'responses/comment', comment: response)
end