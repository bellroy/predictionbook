# frozen_string_literal: true

require 'spec_helper'

describe PredictionGroupsController do
  let(:logged_in_user) { FactoryGirl.create(:user) }
  let(:creator) { FactoryGirl.create(:user) }
  let(:prediction_group) do
    FactoryGirl.create(:prediction_group, predictions: 1, visibility: visibility, creator: creator)
  end
  let(:visibility) { :visible_to_everyone }
  let(:prediction) do
    prediction_group.predictions.first
  end

  before do
    sign_in(logged_in_user) if logged_in_user.present?
    prediction
  end

  describe 'GET show' do
    subject(:show) { get :show, params: { id: prediction_group.id } }

    context 'private and not author' do
      let(:visibility) { :visible_to_creator }

      specify do
        show
        expect(response).to redirect_to root_path
      end
    end

    context 'private and author' do
      let(:creator) { logged_in_user }

      specify do
        show
        expect(response).to be_ok
        expect(assigns[:prediction_group]).to be_a PredictionGroup
        expect(assigns[:events]).to be_an Array
        expect(assigns[:title]).not_to be_nil
      end
    end
  end

  describe 'GET new' do
    subject(:new) { get :new }

    specify do
      new
      expect(response).to be_ok
      expect(assigns[:prediction_group]).to be_a PredictionGroup
      expect(assigns[:prediction_group].predictions.first).to be_a Prediction
      expect(assigns[:statistics]).to be_a Statistics
      expect(assigns[:title]).not_to be_nil
    end
  end

  describe 'POST create' do
    subject(:create) { post :create, params: params }

    let(:params) do
      { prediction_group: { description: 'I believe my face is:' } }
    end
    let(:fake_grp) do
      prediction = instance_double(Prediction)
      instance_double(PredictionGroup, default_prediction: prediction, save: save_result)
    end

    before do
      updated_prediction_group = instance_double(UpdatedPredictionGroup, prediction_group: fake_grp)
      expect(UpdatedPredictionGroup).to receive(:new).and_return(updated_prediction_group)
    end

    context 'save successful' do
      let(:save_result) { true }

      specify do
        create
        expect(response).to redirect_to prediction_group_path(fake_grp)
      end
    end

    context 'save unsuccessful' do
      let(:save_result) { false }

      specify do
        create
        expect(response).to render_template 'new'
      end
    end
  end

  describe 'GET edit' do
    subject(:edit) { get :edit, params: { id: prediction_group.id } }

    before { prediction }

    context 'private and not author' do
      let(:visibility) { :visible_to_creator }

      specify do
        edit
        expect(response).to redirect_to root_path
      end
    end

    context 'private and author' do
      let(:creator) { logged_in_user }

      specify do
        edit
        expect(response).to be_ok
        expect(assigns[:prediction_group]).to be_a PredictionGroup
        expect(assigns[:title]).not_to be_nil
      end
    end
  end

  describe 'PUT update' do
    subject(:update) { post :update, params: params }

    let(:params) do
      { id: prediction_group.id, prediction_group: { description: 'I believe my face is:' } }
    end

    context 'not author' do
      specify do
        update
        expect(response).to redirect_to root_path
      end
    end

    context 'author' do
      let(:creator) { logged_in_user }
      let(:fake_grp) { instance_double(PredictionGroup, save: save_result) }

      before do
        updated_prediction_group = instance_double(UpdatedPredictionGroup, prediction_group: fake_grp)
        expect(UpdatedPredictionGroup).to receive(:new).and_return(updated_prediction_group)
      end

      context 'save successful' do
        let(:save_result) { true }

        specify do
          update
          expect(response).to redirect_to prediction_group_path(fake_grp)
        end
      end

      context 'save unsuccessful' do
        let(:save_result) { false }

        specify do
          update
          expect(response).to render_template 'edit'
        end
      end
    end
  end
end
