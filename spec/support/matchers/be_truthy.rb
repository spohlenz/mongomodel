RSpec::Matchers.define(:be_truthy) do
  match do |object|
    !!object
  end
end
