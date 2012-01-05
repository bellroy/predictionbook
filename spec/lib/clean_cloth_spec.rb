require 'spec_helper'

include CleanCloth
describe CleanCloth do
  
  def markup(text)
    CleanCloth.new(text).to_html
  end
  
  describe 'after manipulation' do
    def transform(text)
      CleanCloth.new(text).reverse.upcase[0..-1].reverse.downcase.to_html
    end
  	
    it 'should still filter html' do
      transform('<br />').should == '&lt;br /&gt;'
    end
    
    it 'should still not support classes' do
      transform('%(id)span%').should == '<span>span</span>'
    end
    
    it 'should still not support styles' do
      transform('%{color:red;}span%').should == '<span>span</span>'
    end
    
  	it 'should still not support block elements' do
  	  transform('h1. text').should == "h1. text"
  	  transform('paragraph text').should == 'paragraph text'
	  end
	  
	  it 'should still support inline elements' do
  	  transform('_text_').should == '<em>text</em>'
  	end
  	
  	it 'should still markup links with rel="nofollow"' do
  	  transform('"google":http://google.com').should == '<a href="http://google.com" rel="nofollow">google</a>'
	  end
  end
  
  describe 'to_html' do
    it 'should markup links with rel="nofollow"' do
      markup('"Google":http://google.com').should == '<a href="http://google.com" rel="nofollow">Google</a>'
    end
    
    describe 'images' do
      it 'should markup images as links' do
        markup("!2girls1cup.jpg!").should == '<a href="2girls1cup.jpg" rel="nofollow">2girls1cup.jpg [pic]</a>'
      end
      it 'should use the title as the link text' do
        markup("!image(title)!").should == '<a href="image" rel="nofollow">title [pic]</a>'
      end
    end
    
    describe 'valid elements' do
      { "_em_"      => "<em>em</em>",
        "*strong*"  => "<strong>strong</strong>",
        "a ^2^"     => "a <sup>2</sup>",
        " -sure- "  => " <del>sure</del> ",
        " +sure+ "  => " <ins>sure</ins> ",
        "[-sure-]"  => "<del>sure</del>",
        "[+sure+]"  => "<ins>sure</ins>",
        "@code@"    => "<code>code</code>",
        "??name??"  => "<cite>name</cite>",
        "(TM)"      => "&#8482;",
        "(R)"       => "&#174;",
        "(C)"       => "&#169;",
        "..."       => "&#8230;",
        '"quot"'    => "&#8220;quot&#8221;",
        "--"        => "&#8212;",
        "a - a"     => "a &#8211; a",
        "2 x 2"     => "2 &#215; 2",
        "~2~"       => "<sub>2</sub>",
        "%span%"    => "<span>span</span>"
      }.each do |raw, markupd|
        it "should markup #{raw} into #{markupd}" do
          markup(raw).should == markupd
        end
      end
    end
    
    describe 'invalid elements' do
      ["p stuff", '\n', "* list item",
        "p))). right ident 3em", "fn1. footnote", "bq. a block quote", "h1. big and bold",
        "reference a footnone[1]", "[hobix]http://hobix.com", " [some] [text] [4] [u] [] ",
        "ab(abbrev)", "| name | age | sex |", " == notextile == "
      ].each do |raw|
        it "should leave #{raw} alone" do
          markup(raw).should == raw
        end
      end
    end

    it 'should dissallow classes' do
      markup('"(class)b(title)":http://a.com').should == 
        '<a href="http://a.com" title="title" rel="nofollow">b</a>'
      markup('%(class)span%').should == "<span>span</span>"
    end
    it 'should dissallow styles' do
      markup("%{color:red}no style%").should == '<span>no style</span>'
    end
    it 'should dissallow ids' do
      markup("%(#big-red)no id%").should == '<span>no id</span>'
    end
    
    describe 'html' do
      it 'should escape' do
        markup("<br />").should == '&lt;br /&gt;'
        markup("<br>").should == '&lt;br&gt;'
        markup("<plaintext>HAHAHAHA</plaintext>").should == '&lt;plaintext&gt;HAHAHAHA&lt;/plaintext&gt;'
      end
      it 'should escape inside nomarkup tag' do
        markup(' == <plaintext></plaintext> == ').should == ' == &lt;plaintext&gt;&lt;/plaintext&gt; == '
      end
      it 'should escape inside normal tags' do
        markup(' _a <br /> b_ ').should == ' <em>a &lt;br /&gt; b</em> '
      end
    end
    
    it 'should remove \n' do
       markup("ln \n ha").should == "ln  ha"
    end
  end  
end
