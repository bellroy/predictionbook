class Array
  def rsort(field)
    sort { |first, second| second.send(field) <=> first.send(field) }
  end
end
