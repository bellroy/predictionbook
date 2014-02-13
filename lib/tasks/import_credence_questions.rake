desc "Import credence questions."
task :import_credence_questions => :environment do
  doc = Nokogiri::XML(open('db/questions/OfficialCfarQuestions.xml'))
  doc.search('QuestionGenerator').each do |gen|
    cq = CredenceQuestionGenerator.new(
      :enabled => gen['Used'].to_s == 'y',
      :type => gen['Type'].to_s,
      :text => gen['QuestionText'].to_s,
      :prefix => gen['InfoPrefix'].to_s,
      :suffix => gen['InfoSuffix'].to_s,
      :adjacentWithin => gen['AdjacentWithin'].to_s.to_i,
      :weight => gen['Weight'].to_s.to_f)
    cq.save

    puts
    puts gen['QuestionText']
    gen.search('Answer').each do |ans|
      puts "#{ans['Text']} => #{ans['Value']}"
    end
  end
end
