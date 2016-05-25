require 'spec_helper'

describe CredenceGamesController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe '#show' do
    subject(:show) { get :show, id: 'try' }

    it 'should not error if the db has not been initialized' do
      expect { show }.not_to raise_error
    end

    describe 'Receiving a question' do
      let!(:question) { FactoryGirl.create(:credence_question) }
      let!(:answers) { FactoryGirl.create_list(:credence_answer, 2, credence_question: question) }

      it 'should assign @game and @question' do
        show
        expect(assigns[:game]).to eq user.credence_game
        expect(assigns[:response]).to eq user.credence_game.current_response
      end

      context 'should set @show_graph only for certain questions' do
        before do
          allow_any_instance_of(CredenceGame).to receive(:num_answered).and_return(num_answered)
          show
        end

        subject { assigns[:show_graph] }

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
    let!(:game) { FactoryGirl.create(:credence_game, user: user) }

    subject(:destroy) { delete :destroy, id: game.id }

    specify do
      expect { destroy }.to change { CredenceGame.count }.from(1).to(0)
    end
  end
end
