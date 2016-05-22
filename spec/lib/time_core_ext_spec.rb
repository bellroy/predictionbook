require 'spec_helper'

describe 'Time core extensions' do
  describe 'noon' do
    it 'sets Time instance to 12:00:00' do
      expect(Time.utc(2000, 11, 23, 10, 50, 44).noon).to eq Time.utc(2000, 11, 23, 12, 00, 00)
    end
  end
end

describe 'Chronic regression test' do
  describe 'crash on "100 years from now"' do
    it 'does not raise an exception' do
      expect { Chronic.parse('100 years from now') }.not_to raise_error
    end

    it 'returns the date' do
      now = Time.zone.now
      future = now.utc + 100.years
      expect(Chronic.parse('100 years from now').to_s(:db)).to eq future.to_s(:db)
    end
  end
end
