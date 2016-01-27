desc "Import credence questions."
task import_credence_questions: :environment do
  file = ENV['REPOSITORY']
  if file.nil?
    puts "You must supply a repository:\n" \
      "    rake import_credence_questions REPOSITORY=path/to/file.xml\n" \
      "Some repositories can be found in db/questions."
    next
  end

  doc = Nokogiri::XML(open(file))
  id_prefix = doc.at('Questions')['IdPrefix']
  doc.search('QuestionGenerator').each do |gen|
    cq = CredenceQuestion.create_from_element!(gen, id_prefix)
    if cq
      puts "Created question with #{cq.credence_answers.count} answers: #{cq.text}"
    end
  end
end
