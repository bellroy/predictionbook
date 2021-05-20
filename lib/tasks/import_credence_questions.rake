require "#{Rails.root}/lib/credence_question_generator"

desc 'Import credence questions.'
task import_credence_questions: :environment do
  file = ENV['REPOSITORY']

  if file.nil?
    puts "You must supply a repository:\n" \
      "    rake import_credence_questions REPOSITORY=path/to/file.xml\n" \
      'Some repositories can be found in db/questions.'
    next
  end

  CredenceQuestionGenerator.new(file).call
end
