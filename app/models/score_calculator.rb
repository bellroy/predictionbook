class ScoreCalculator
  DECIMAL_PLACES = 2
  DEFAULT_SCORE = 1
  EPISILON = 0.005

  attr_reader :wagers

  def self.calculate(wagers)
    new(wagers).calculate
  end

  def initialize(wagers)
    @wagers = wagers.includes(prediction: [:judgements])
  end

  def calculate
    return DEFAULT_SCORE if scorable_wagers.count.zero?
    score = 0

    scorable_wagers.each do |wager|
      if wager.correct?
        score += Math.log(percent_confidence(wager))
      else
        score += Math.log(1 - percent_confidence(wager))
      end
    end

    ((Math.log(0.5) * scorable_wagers.count) / score).round(DECIMAL_PLACES)
  end

  private

  def percent_confidence(wager)
    percent = wager.relative_confidence / 100.0
    return 1 - EPISILON if percent == 1
    percent
  end

  def scorable_wagers
    @scorable_wagers ||= wagers.reject { |wager| wager.unknown? }
  end
end
