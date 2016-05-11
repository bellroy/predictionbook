class CredenceStatistics < BaseStatistics
  def initialize(responses)
    groups = Hash.new { |h,k| h[k] = GroupedWagers.new }

    responses.each { |response|
      groups[response.answer_credence].add(response.answer_correct? response.given_answer)
    }

    @intervals = Hash[ groups.map { |credence, group|
      [ credence, Interval.new(credence, group.count, group.accuracy) ]
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
