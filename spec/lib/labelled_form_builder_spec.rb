# frozen_string_literal: true

require 'spec_helper'

describe LabelledFormBuilder do
  class BogusTemplate
    include ActionView::Helpers::TagHelper

    def text_field(*_args); end

    def label(*_args); end

    def capture(*_args)
      yield.to_s
    end
  end

  let(:errors) { {} }
  let(:record) { instance_double(ActiveRecord::Base, errors: errors) }
  let(:template) { BogusTemplate.new }
  let(:builder) { described_class.new('record_name', record, template, {}) }

  it 'adds a label to every text field' do
    expect(template).to receive(:label).with('record_name', :name, anything, anything)
    builder.text_field(:name)
  end

  it 'delegates text field to template' do
    expect(template).to receive(:text_field).with('record_name', :name, anything)
    builder.text_field(:name)
  end

  it 'adds the error message in the generated field if it has an error' do
    errors[:name] = 'error_message'
    expect(builder.text_field(:name)).to match(/error_message/)
  end

  it 'renders trailing content after the text field inside the p tag' do
    expect(template).to receive(:text_field).and_return('textfield')
    expect(builder.text_field(:name, trailing_content: '#end')).to match(%r{textfield#end</p>$})
  end
end
