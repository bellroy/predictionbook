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
  doc.search('QuestionGenerator').each do |gen|
    next if gen['Type'] != 'Sorted'

    cq = CredenceQuestion.new(
      enabled: gen['Used'].to_s == 'y',
      type: gen['Type'].to_s,
      text: gen['QuestionText'].to_s,
      prefix: gen['InfoPrefix'].to_s,
      suffix: gen['InfoSuffix'].to_s,
      adjacent_within: gen['AdjacentWithin'].to_s.to_i,
      weight: gen['Weight'].to_s.to_f
    )
    cq.save!

    rank = -1
    last_val = nil
    gen.search('Answer').each do |ans|
      cur_val = ans['Value'].to_s
      if last_val != cur_val
        rank += 1
        last_val = cur_val
      end

      cq.credence_answers.create!(
        text: ans['Text'],
        value: cur_val,
        rank: rank
      )
    end
    puts "Created question with #{cq.credence_answers.count} answers: #{cq.text}"
  end
end
