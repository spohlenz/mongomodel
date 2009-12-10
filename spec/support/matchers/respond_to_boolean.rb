Spec::Matchers.define(:respond_to_boolean) do |method|
  match do |instance|
    instance.respond_to?(method) && is_boolean?(instance.send(method))
  end
  
  description do
    "should respond to #{method} and return boolean"
  end
  
  failure_message_for_should do |instance|
    "expected #{instance.inspect} to respond to #{method} and return boolean"
  end
  
  def is_boolean?(value)
    value == true || value == false
  end
end
