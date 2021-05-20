# frozen_string_literal: true

require 'spec_helper'

describe CredenceGame do
  it 'calculates score correctly' do
    game = FactoryBot.create(:credence_game, num_answered: 3, score: 21)
    expect(game.average_score).to eq 7
  end

  it 'gives 0 score with no answered questions' do
    game = FactoryBot.create(:credence_game, num_answered: 0, score: 0)
    expect(game.average_score).to eq 0
  end

  it 'finds answered questions' do
    question = FactoryBot.create(:credence_question)
    answers = FactoryBot.create_list(:credence_answer, 2, credence_question: question)
    game = FactoryBot.create(:credence_game) # should create a random response
    FactoryBot.create(:credence_game_response, credence_game: game, credence_question: question,
                                               first_answer: answers.first,
                                               second_answer: answers.second)
    expect(game.responses.count).to eq 2
    expect(game.responses_selected_by_users.length).to eq 1
  end

  it 'finds most recently answered questions' do
    question = FactoryBot.create(:credence_question)
    answers = FactoryBot.create_list(:credence_answer, 2, credence_question: question)
    game = FactoryBot.create(:credence_game) # should create a random response
    last_response = FactoryBot.create(
      :credence_game_response,
      credence_game: game, credence_question: question,
      first_answer: answers.first, second_answer: answers.second
    )

    expect(game.most_recently_answered(1).length).to eq 1
    expect(game.most_recently_answered(1).first).to eq last_response
    expect(game.most_recently_answered(3).length).to eq 1
    expect(game.most_recently_answered(3).first).to eq last_response
  end

  describe '#add_score' do
    let(:question) { FactoryBot.create(:credence_question) }
    let(:answers) do
      FactoryBot.create_list(:credence_answer, 2, credence_question: question)
    end
    let(:game) { FactoryBot.create(:credence_game) }
    let(:response) do
      FactoryBot.create(
        :credence_game_response,
        credence_game: game, credence_question: question,
        first_answer: answers.first, second_answer: answers.second
      )
    end
    let(:other_response) { FactoryBot.create(:credence_game_response) }

    it 'increments the number answered' do
      response

      expect{ game.add_score(1) }.to change{ game.num_answered }.from(0).to(1)
    end

    it 'increments the number answered' do
      response

      expect{ game.add_score(2) }.to change{ game.score }
    end

    it 'sets the current response' do
      response && other_response

      expect{ game.add_score(3) }.to change{ game.current_response }.from(nil)
    end
  end
end
