desc "Import credence questions."
task :import_credence_questions => :environment do
  doc = Nokogiri::XML(open('db/questions/OfficialCfarQuestions.xml'))
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

    # This real_val is wrong. It breaks silently on things like "8,800" and
    # "12/3/1999" which show up in the question list.
    gen.search('Answer').each do |ans|
      cq.credence_answers.create(:text => ans['Text'],
                                 :display_val => ans['Value'].to_s,
                                 :real_val => ans['Value'].to_s.to_f)
    end
  end
end
