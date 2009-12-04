Spec::Matchers.define(:run_callbacks) do |*callbacks|
  match do |instance|
    instance.history == expand_callbacks(callbacks)
  end
  
  failure_message_for_should do |instance|
    "expected #{instance.inspect} to run callbacks #{callbacks.inspect}"
  end
  
  def expand_callbacks(callbacks)
    callbacks.map { |c| [ [c, :string], [c, :proc], [c, :object], [c, :block] ] }.inject([]) { |result, c| result + c }
  end
end
