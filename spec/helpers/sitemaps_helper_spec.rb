# frozen_string_literal: true

require 'spec_helper'

describe SitemapsHelper do
  include described_class

  describe '#w3c_date' do
    it 'returns a valid W3C Datetime' do
      target_date = DateTime.parse('01/01/2017 00:00:00')
      expect(w3c_date(target_date)).to eq('2017-01-01T00:00:00+00:00')
    end
  end
end
