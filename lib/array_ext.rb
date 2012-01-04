class Array
  def rsort(field)
    sort {|a,b| b.send(field) <=> a.send(field)}
  end
  
  alias_method :limit, :first
end
