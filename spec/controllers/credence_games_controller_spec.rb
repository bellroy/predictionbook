# frozen_string_literal: true

require 'spec_helper'

describe CredenceGamesController do
  let(:user) { FactoryBot.create(:user) }

  before { sign_in user }

  describe '#show' do
    subject(:show) { get :show, params: { id: 'try' } }

    it 'does not error if the db has not been initialized' do
      expect { show }.not_to raise_error
    end

    describe 'Receiving a question' do
      let!(:question) { FactoryBot.create(:credence_question) }
      let!(:answers) { FactoryBot.create_list(:credence_answer, 2, credence_question: question) }

      it 'assigns @game and @question' do
        show
        expect(assigns[:game]).to eq user.credence_game
        expect(assigns[:response]).to eq user.credence_game.current_response
      end

      context 'should set @show_graph only for certain questions' do
        subject { assigns[:show_graph] }

        before do
          allow_any_instance_of(CredenceGame).to receive(:num_answered).and_return(num_answered)
          show
        end

        context '10 answered' do
          let(:num_answered) { 10 }

          it { is_expected.to be false }
        end

        context '20 answered' do
          let(:num_answered) { 20 }

          it { is_expected.to be true }
        end

        context '25 answered' do
          let(:num_answered) { 25 }

          it { is_expected.to be false }
        end
      end
    end
  end

  describe '#destroy' do
    subject(:destroy) { delete :destroy, params: { id: game.id } }

    let(:game) { FactoryBot.create(:credence_game, user: user) }

    before { game }

    specify do
      expect { destroy }.to change(CredenceGame, :count).from(1).to(0)
    end
  end
end
