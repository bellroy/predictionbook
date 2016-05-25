class CredenceStatistics < BaseStatistics
  attr_reader :groups, :intervals

  def initialize(responses)
    self.groups = Hash.new { |hash, key| hash[key] = GroupedWagers.new }

    responses.each do |response|
      groups[response.answer_credence].add_figures_for_response(response)
    end

    create_intervals
  end

  private

  attr_writer :groups, :intervals

  def create_intervals
    self.intervals = groups.map do |credence, group|
      [credence, group.interval(credence)]
    end.to_h
  end

  class GroupedWagers
    def initialize
      self.count = 0
      self.correct = 0
    end

    def add_figures_for_response(response)
      response_correct = response.answer_correct?
      self.count = count + 1
      self.correct = correct + 1 if response_correct
    end

    def interval(credence)
      BaseStatistics::Interval.new(credence, count, accuracy)
    end

    private

    attr_accessor :count, :correct

    def accuracy
      count > 0 ? (correct.to_f / count) : 0
    end
  end
end
