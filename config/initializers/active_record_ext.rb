class <<ActiveRecord::Base
  # replace blank/whitespace only strings with a nil
  def nillify_blank(*attrs)
    attrs.each do |attr|
      define_method "#{attr}=" do |value|
        self[attr] = value.blank? ? nil : value
      end
    end
  end
end
