Spec::Matchers.define(:be_a_subclass_of) do |ancestor|
  match do |klass|
    klass.ancestors.include?(ancestor)
  end
end
