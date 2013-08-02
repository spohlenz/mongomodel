RSpec::Matchers.define(:find_with) do |find_options|
  extend RSpec::Mocks::ExampleMethods
  
  match do |klass|
    selector, options = MongoModel::MongoOptions.new(klass, find_options).to_a
    
    result = double('find result', :to_a => (@result || []).map { |d| d.to_mongo })
    klass.collection.should_receive(:find).once.with(selector, options).and_return(result)
    
    true
  end
  
  def and_return(result)
    @result = result
    self
  end
end

RSpec::Matchers.define(:count_with) do |find_options|
  extend RSpec::Mocks::ExampleMethods
  
  match do |klass|
    selector, options = MongoModel::MongoOptions.new(klass, find_options).to_a
    result = double('find result')
    
    klass.collection.should_receive(:find).once.with(selector, options).and_return(result)
    result.should_receive(:count).once.and_return(@count || 5)
    
    true
  end
  
  def and_return(count)
    @count = count
    self
  end
end
