class LabelledFormBuilder < ActionView::Helpers::FormBuilder

  def add_input_class!(options)
    case options[:class]
    when String
      options[:class] = "#{options[:class]} input"
    when Array
      options[:class] << 'input'
    when nil
      options[:class] = 'input'
    end
  end

  def check_box(method, options={})
    labelling_surround(method, options.merge(:label_containing => true)) do |method, options|
      super(method,options)
    end
  end

  def text_field(method, options={})
    add_input_class!(options)
    labelling_surround(method, options) do |method, options|
      super(method, options)
    end
  end

  def text_area(method, options={})
    add_input_class!(options)
    labelling_surround(method, options) do |method, options|
      super(method, options)
    end
  end

  def password_field(method, options={})
    add_input_class!(options)
    labelling_surround(method, options) do |method, options|
      super(method,options.merge(:value => ''))
    end
  end

  def confidence_field(method, options={})
    new_class = "#{options.delete(:class)} confidence".strip
    new_options = {:trailing_content => ' % chance',:maxlength => 3, :class => new_class}
    text_field(method, new_options.merge(options))
  end

  def timezone_field(method, options={})
    zones = ActiveSupport::TimeZone.all.sort_by(&:utc_offset).collect do |tz|
      ["#{tz.name} #{tz.to_s.sub(tz.name,'')}", tz.name]
    end
    labelling_surround(method,options) do |method, options|
      select(method, zones, {:include_blank => 'Default to UTC'}.merge(options))
    end
  end

  def submit(text, options={})
    @template.content_tag(:p, super).html_safe
  end

  private
  def labelling_surround(method, options)
    trailing_content, preview, label_containing, label_string = extract_labelling_options!(options)
    label_string ||= method.to_s.humanize

    error = object.errors[method]
    control = yield(method, {:size => nil}.merge(options)) #size isn't valid in html5
    outer_class = error ? 'error' : nil
    @template.content_tag(:p, :class => outer_class) do
      content = if label_containing
                  [label(method, control.to_s + label_string)]
                else
                  [label(method, label_string), control]
                end
      content << trailing_content if trailing_content
      content << error_content(method) if error
      content << preview_content(method) if preview
      content.join.html_safe
    end
  end

  def error_content(method)
    @template.content_tag(
      :span,
      [object.errors[method]].flatten.first,
      :class => 'message'
    ).html_safe
  end

  def counter_content(method, amount)
    @template.content_tag(:label, amount, :class => 'counter', :for => "#{object_name}_#{method}").html_safe
  end

  def preview_content(method)
    @template.content_tag(
      :span,
      '',
      :id => "#{object_name}_#{method}_preview",
      :class => 'preview'
    ).html_safe
  end

  def extract_labelling_options!(options)
    names = [:trailing_content, :preview, :label_containing, :label]
    names.collect { |name| options.delete(name) }
  end
end
