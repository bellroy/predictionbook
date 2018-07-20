# frozen_string_literal: true

require 'spec_helper'

describe CredenceGameResponsesController do
  let(:user) { FactoryBot.create(:user) }
  let!(:question) { FactoryBot.create(:credence_question) }
  let!(:answers) { FactoryBot.create_list(:credence_answer, 2, credence_question: question) }
  let!(:game) { FactoryBot.create(:credence_game, user: user) }
  before { sign_in user }

  context '#update' do
    let(:response_id) { game.current_response.id }
    let(:given_answer) { game.current_response.correct_index }
    let(:answer_credence) { 51 }
    let(:response_attributes) { { given_answer: given_answer, answer_credence: answer_credence } }

    subject(:update) { post :update, params: { id: response_id, response: response_attributes } }

    def check_flash(correct, score)
      expect(flash[:correct]).to eq correct
      expect(flash[:score]).to eq score
      expect(flash[:message]).to be_kind_of(String)
    end

    context 'response_id is current response id' do
      it 'should update' do
        expect { update }.to change { game.current_response.reload.answered_at }
      end
    end

    context 'response_id is a different response' do
      let(:response_id) do
        FactoryBot.create(:credence_game_response, credence_game: other_game).id
      end

      context 'game belongs to someone else' do
        let(:other_game) { FactoryBot.create(:credence_game) }
        specify do
          update
          expect(response).to be_forbidden
        end
      end
    end

    context 'should set the flash correctly' do
      before { update }

      context 'first answer' do
        specify { check_flash(true, 3) }

        context 'higher credence' do
          let(:answer_credence) { 70 }
          specify { check_flash(true, 49) }
        end

        context 'credence too low' do
          let(:answer_credence) { 0 }
          specify { expect(flash[:error]).not_to be_empty }
        end

        context 'credence too high' do
          let(:answer_credence) { 100 }
          specify { expect(flash[:error]).not_to be_empty }
        end
      end

      context 'second answer' do
        let(:given_answer) { game.current_response.correct_index + 1 }

        specify { check_flash(false, -3) }

        context 'higher credence' do
          let(:answer_credence) { 70 }
          specify { check_flash(false, -74) }
        end
      end
    end
  end
end
