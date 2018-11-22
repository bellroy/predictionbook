# frozen_string_literal: true

require 'spec_helper'

describe CredenceGameResponse do
  let(:correct_index) { 0 }
  let(:given_answer) { 0 }
  let(:answer_credence) { 50 }
  let(:response) do
    FactoryBot.build(:credence_game_response, correct_index: correct_index,
                                              given_answer: given_answer,
                                              answer_credence: answer_credence)
  end

  describe '#answer_correct?' do
    subject { response.answer_correct? }

    it { is_expected.to be true }

    context 'given answer is different' do
      let(:given_answer) { 1 }

      it { is_expected.to be false }
    end
  end

  describe '#score_answer' do
    subject { response.score_answer }

    context 'right answer' do
      { 50 => 0, 51 => 3, 60 => 26, 70 => 49, 80 => 68, 90 => 85,
        99 => 99 }.each do |credence, score|
        specify do
          response.assign_attributes(given_answer: 0, answer_credence: credence)
          expect(response.score_answer).to eq [true, score]
        end
      end
    end

    context 'wrong answer' do
      { 50 => 0, 51 => -3, 60 => -32, 70 => -74, 80 => -132, 90 => -232,
        99 => -564 }.each do |credence, score|
        specify do
          response.assign_attributes(given_answer: 1, answer_credence: credence)
          expect(response.score_answer).to eq [false, score]
        end
      end
    end

    context 'credence out of bounds' do
      [[0, 0], [0, 100], [1, 0], [1, 100]].each do |array|
        specify do
          response.assign_attributes(given_answer: array.first, answer_credence: array.last)
          expect(response.score_answer).to be_nil
        end
      end
    end
  end
end
