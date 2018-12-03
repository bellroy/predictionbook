# frozen_string_literal: true

require 'spec_helper'

include CleanCloth
describe CleanCloth do
  describe 'after manipulation' do
    subject { described_class.new(text).reverse.upcase[0..-1].reverse.downcase.to_html }

    context 'html' do
      let(:text) { '<br />' }

      it { is_expected.to eq '&lt;br /&gt;' }
    end

    context 'still does not support classes' do
      let(:text) { '%(id)span%' }

      it { is_expected.to eq '<span>span</span>' }
    end

    context 'still does not support styles' do
      let(:text) { '%{color:red;}span%' }

      it { is_expected.to eq '<span>span</span>' }
    end

    context 'still does not support block elements' do
      let(:text) { 'h1. text' }

      it { is_expected.to eq 'h1. text' }
    end

    context 'just text' do
      let(:text) { 'paragraph text' }

      it { is_expected.to eq 'paragraph text' }
    end

    context 'still supports inline elements' do
      let(:text) { '_text_' }

      it { is_expected.to eq '<em>text</em>' }
    end

    context 'still marks up links with rel="nofollow"' do
      let(:text) { '"google":http://google.com' }

      it { is_expected.to eq '<a href="http://google.com" rel="nofollow">google</a>' }
    end
  end

  describe 'to_html' do
    subject { described_class.new(text).to_html }

    context 'marks up links with rel="nofollow"' do
      let(:text) { '"Google":http://google.com' }

      it { is_expected.to eq '<a href="http://google.com" rel="nofollow">Google</a>' }
    end

    describe 'images' do
      context 'marks up images as links' do
        let(:text) { '!2girls1cup.jpg!' }

        it { is_expected.to eq '<a href="2girls1cup.jpg" rel="nofollow">2girls1cup.jpg [pic]</a>' }
      end

      context 'uses the title as the link text' do
        let(:text) { '!image(title)!' }

        it { is_expected.to eq '<a href="image" rel="nofollow">title [pic]</a>' }
      end
    end

    describe 'valid elements' do
      { '_em_' => '<em>em</em>',
        '*strong*' => '<strong>strong</strong>',
        'a ^2^' => 'a <sup>2</sup>',
        ' -sure- ' => ' <del>sure</del> ',
        ' +sure+ ' => ' <ins>sure</ins> ',
        '[-sure-]' => '<del>sure</del>',
        '[+sure+]' => '<ins>sure</ins>',
        '@code@' => '<code>code</code>',
        '??name??' => '<cite>name</cite>',
        '(TM)' => '&#8482;',
        '(R)' => '&#174;',
        '(C)' => '&#169;',
        '...' => '&#8230;',
        '"quot"' => '&#8220;quot&#8221;',
        '--' => '&#8212;',
        'a - a' => 'a &#8211; a',
        '2 x 2' => '2 &#215; 2',
        '~2~' => '<sub>2</sub>',
        '%span%' => '<span>span</span>' }.each do |raw, markupd|
        context "marks up #{raw} into #{markupd}" do
          let(:text) { raw }

          it { is_expected.to eq markupd }
        end
      end
    end

    describe 'invalid elements' do
      ['p stuff', '\n', '* list item',
       'p))). right ident 3em', 'fn1. footnote', 'bq. a block quote', 'h1. big and bold',
       'reference a footnone[1]', '[hobix]http://hobix.com', ' [some] [text] [4] [u] [] ',
       'ab(abbrev)', '| name | age | sex |', ' == notextile == '].each do |raw|
        context "leaves #{raw} alone" do
          let(:text) { raw }

          it { is_expected.to eq raw }
        end
      end
    end

    context 'should dissallow classes' do
      context 'class with link' do
        let(:text) { '"(class)b(title)":http://a.com' }

        it { is_expected.to eq '<a href="http://a.com" title="title" rel="nofollow">b</a>' }
      end

      context 'class with span' do
        let(:text) { '%(class)span%' }

        it { is_expected.to eq '<span>span</span>' }
      end
    end

    context 'should dissallow styles' do
      let(:text) { '%{color:red}no style%' }

      it { is_expected.to eq '<span>no style</span>' }
    end

    context 'should dissallow ids' do
      let(:text) { '%(#big-red)no id%' }

      it { is_expected.to eq '<span>no id</span>' }
    end

    describe 'html' do
      context 'should escape' do
        context 'closed break tags' do
          let(:text) { '<br />' }

          it { is_expected.to eq '&lt;br /&gt;' }
        end

        context 'open break tags' do
          let(:text) { '<br>' }

          it { is_expected.to eq '&lt;br&gt;' }
        end

        context 'plaintext tags' do
          let(:text) { '<plaintext>HAHAHAHA</plaintext>' }

          it { is_expected.to eq '&lt;plaintext&gt;HAHAHAHA&lt;/plaintext&gt;' }
        end
      end

      context 'should escape inside nomarkup tag' do
        let(:text) { ' == <plaintext></plaintext> == ' }

        it { is_expected.to eq ' == &lt;plaintext&gt;&lt;/plaintext&gt; == ' }
      end

      context 'should escape inside normal tags' do
        let(:text) { ' _a <br /> b_ ' }

        it { is_expected.to eq ' <em>a &lt;br /&gt; b</em> ' }
      end
    end

    context 'should remove \n' do
      let(:text) { "ln \n ha" }

      it { is_expected.to eq 'ln  ha' }
    end
  end
end
