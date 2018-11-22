# frozen_string_literal: true

require 'spec_helper'

describe Visibility do
  describe '.select_options_html' do
    subject(:html) do
      described_class.select_options_html([group], current_visibility, current_group_id)
    end

    let(:current_visibility) { 'visible_to_creator' }
    let(:current_group_id) { nil }
    let(:group) { FactoryBot.create(:group, name: 'TrikeApps') }

    specify do
      expect(html).to eq '<option value="visible_to_everyone" >Visible to everyone</option>' \
                         '<option value="visible_to_creator" selected>Visible to creator</option>' \
                         "<option value=\"visible_to_group_#{group.id}\" >Visible to TrikeApps group</option>"
    end

    context 'visible to group but not this group' do
      let(:current_visibility) { 'visible_to_group' }
      let(:current_group_id) { group.id - 1 }

      specify do
        expect(html).to eq '<option value="visible_to_everyone" >Visible to everyone</option>' \
                           '<option value="visible_to_creator" >Visible to creator</option>' \
                           "<option value=\"visible_to_group_#{group.id}\" >Visible to TrikeApps group</option>"
      end
    end

    context 'visible to group but not this group' do
      let(:current_visibility) { 'visible_to_group' }
      let(:current_group_id) { group.id }

      specify do
        expect(html).to eq '<option value="visible_to_everyone" >Visible to everyone</option>' \
                           '<option value="visible_to_creator" >Visible to creator</option>' \
                           "<option value=\"visible_to_group_#{group.id}\" selected>Visible to TrikeApps group</option>"
      end
    end
  end
end
