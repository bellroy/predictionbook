desc "Import credence questions."
task :import_credence_questions => :environment do
  file = ENV['REPOSITORY']
  if file.nil?
    puts "You must supply a repository:\n" \
      "    rake import_credence_questions REPOSITORY=path/to/file.xml\n" \
      "Some repositories can be found in db/questions."
    next
  end

  doc = Nokogiri::XML(open(file))
  doc.search('QuestionGenerator').each do |gen|
    next if gen['Type'] != 'Sorted'

    cq = CredenceQuestionGenerator.new(
      :enabled => gen['Used'].to_s == 'y',
      :type => gen['Type'].to_s,
      :text => gen['QuestionText'].to_s,
      :prefix => gen['InfoPrefix'].to_s,
      :suffix => gen['InfoSuffix'].to_s,
      :adjacentWithin => gen['AdjacentWithin'].to_s.to_i,
      :weight => gen['Weight'].to_s.to_f)
    cq.save

    gen.search('Answer').each_with_index do |ans,i|
      cq.credence_answers.create(:text => ans['Text'],
                                 :value => ans['Value'].to_s,
                                 :rank => i)
    end
  end
end
