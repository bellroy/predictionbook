class CredenceStatistics < BaseStatistics
  def initialize(questions)
    groups = Hash.new { |h,k| h[k] = GroupedWagers.new }

    questions.each { |q|
      groups[q.answer_credence].add(q.answer_correct? q.given_answer)
    }

    @intervals = Hash[ groups.map { |cred, group|
      [ cred, Interval.new(cred, group.count, group.accuracy) ]
    } ]
  end

  class GroupedWagers
    attr_reader :count
    def initialize()
      @count = 0
      @correct = 0
    end

    def add(correct)
      @count += 1
      @correct += 1 if correct
    end

    def accuracy
      @count > 0 ? @correct.to_f / @count : 0
    end
  end
end
