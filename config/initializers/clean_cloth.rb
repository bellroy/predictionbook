module CleanCloth
  include RedCloth
  
  module Formatters
    module HTML
      include RedCloth::Formatters::HTML

      def image(opts)
        opts[:href] = opts.delete(:src)
        opts[:name] = opts.delete(:title) || opts[:href].dup
        opts[:name] << " [pic]"
        link(opts)
      end

      def footno(opts)
        "[#{opts[:text]}]"
      end

      def br(opts)
        ""
      end

      def link(opts)
        super opts.merge(:rel => 'nofollow')
      end

      def pba(opts)
        atts = super(opts)
        atts << %{ rel="#{opts[:rel]}"} if opts[:rel]
        atts
      end
    end
  end
  
  class TextileDoc < RedCloth::TextileDoc
    def lite_mode; true; end;
    def filter_html; true; end;
    def filter_ids; true; end;
    def filter_styles; true; end
    def filter_classes; true; end;
    def no_span_caps; true; end;
        
    def to_html(*rules)
      apply_rules(rules)

      to(CleanCloth::Formatters::HTML)
    end
  end
    
  def self.new(string, restrictions = [])
    CleanCloth::TextileDoc.new( string, restrictions )
  end
end
