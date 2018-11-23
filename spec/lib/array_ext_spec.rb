# frozen_string_literal: true

require 'spec_helper'

describe 'Array core extensions' do
  describe 'rsort!' do
    it 'reverses order the elements by the field passed' do
      a = '1'
      b = '2'
      c = '3'
      ary = [a, b, c]
      expect(ary.rsort(:to_i)).to eq [c, b, a]
    end
  end
end
