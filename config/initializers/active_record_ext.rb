class <<ActiveRecord::Base
  # replace blank/whitespace only strings with a nil
  def nillify_blank(*attrs)
    attrs.each do |attr|
      define_method "#{attr}=" do |value|
        self[attr] = value.blank? ? nil : value
      end
    end
  end

  def boolean_accessor_with_default(name, default = nil, &block)
    raise 'Default value or block required' unless !default.nil? || block

    define_method(name, block_given? ? block : Proc.new {default})

    class_eval(<<-EVAL)
      def #{name}=(value)
        class << self; attr_reader :#{name} end
        @#{name} = ActiveRecord::Type::Boolean.new.type_cast_from_database(value)
      end
    EVAL
  end
end
