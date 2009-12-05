Spec::Matchers.define(:run_callbacks) do |*callbacks|
  match do |instance|
    instance.history == expand_callbacks(callbacks)
  end
  
  failure_message_for_should do |instance|
    "expected #{instance.inspect} to run callbacks #{callbacks.inspect} but got #{compress_callbacks(instance.history).inspect}"
  end
  
  def compress_callbacks(callbacks)
    callbacks.inject([]) { |result, (callback, type)|
      result << callback if type == :string
      result
    }
  end
  
  def expand_callbacks(callbacks)
    callbacks.map { |c| [ [c, :string], [c, :proc], [c, :object], [c, :block] ] }.inject([]) { |result, c| result + c }
  end
end
