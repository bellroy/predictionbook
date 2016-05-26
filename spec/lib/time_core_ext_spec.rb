require 'spec_helper'

describe 'Time core extensions' do
  describe 'noon' do
    it 'sets Time instance to 12:00:00' do
      expect(Time.utc(2000, 11, 23, 10, 50, 44).noon).to eq Time.utc(2000, 11, 23, 12, 00, 00)
    end
  end
end
