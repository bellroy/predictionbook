desc 'Import credence questions.'
task import_credence_questions: :environment do
  CredenceGame.destroy_all
  CredenceQuestion.destroy_all

  file = ENV['REPOSITORY']
  if file.nil?
    puts "You must supply a repository:\n" \
      "    rake import_credence_questions REPOSITORY=path/to/file.xml\n" \
      'Some repositories can be found in db/questions.'
    next
  end

  doc = Nokogiri::XML(open(file))
  id_prefix = doc.at('Questions')['IdPrefix']
  doc.search('QuestionGenerator').each do |generator|
    question = CredenceQuestion.create_from_xml_element!(generator, id_prefix)
    if question
      puts "Created question with #{question.answers.count} " \
           "answers: #{question.text}"
    end
  end
end
