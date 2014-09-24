require 'spec_helper'

describe 'Time core extensions' do
  describe 'noon' do
    it 'should set Time instance to 12:00:00' do
      Time.utc(2000,11,23,10,50,44).noon.should == Time.utc(2000,11,23,12,00,00)
    end
  end
end

describe 'Chronic regression test' do

  describe 'crash on "100 years from now"' do
    it 'should not raise an exception' do
      expect { Chronic.parse('100 years from now') }.not_to raise_error
    end

    it 'should return the date' do
      now = Time.now
      future = now.utc + 100.years
      Time.stub(:now).and_return(now)
      Chronic.parse("100 years from now").to_s(:db).should == future.to_s(:db)
    end
  end

end
