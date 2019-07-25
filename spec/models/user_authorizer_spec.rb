require 'spec_helper'

describe UserAuthorizer do
  describe '.call' do
    let(:action) { 'show' }
    let(:another_user) { FactoryBot.create(:user) }
    let(:user) { FactoryBot.create(:user) }
    subject do
      described_class.call(user: user, prediction: prediction, action: action)
    end

    context 'for a user that made a wager' do
      let(:wager) { FactoryBot.build(:response, confidence: 10, user: user) }

      context 'on a prediction created by another user' do
        let(:prediction) do
          FactoryBot.create(
            :prediction,
            creator: another_user,
            responses: [wager],
            visibility: visibility
          )
        end

        context 'that is still public' do
          let(:visibility) { :visible_to_everyone }

          it 'is authorized to show' do
            expect(subject).to be(true)
          end
        end

        context 'that has been made private' do
          let(:visibility) { :visible_to_creator }

          it 'is still authorized to show' do
            expect(subject).to be(true)
          end
        end
      end

      context 'on a prediction created by that same user' do
        let(:prediction) do
          FactoryBot.create(
            :prediction,
            creator: user,
            visibility: visibility
          )
        end

        context 'that is public' do
          let(:visibility) { :visible_to_everyone }

          it 'is authorized to show' do
            expect(subject).to be(true)
          end
        end

        context 'that has been made private' do
          let(:visibility) { :visible_to_creator }

          it 'is still authorized to show' do
            expect(subject).to be(true)
          end
        end
      end
    end

    context 'for a user that has no previous history with a given prediction' do
      let(:prediction) do
        FactoryBot.create(
          :prediction,
          creator: another_user,
          visibility: visibility
        )
      end

      context 'but that prediction is public' do
        let(:visibility) { :visible_to_everyone }

        it 'is authorized to show' do
          expect(subject).to be(true)
        end
      end

      context 'and that prediction has been made private' do
        let(:visibility) { :visible_to_creator }

        it 'is not authorized to show' do
          expect(subject).to be(false)
        end
      end
    end
  end
end
