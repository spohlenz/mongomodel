require 'spec/mocks'

module DocumentFinderStubs
  include Spec::Mocks::ExampleMethods
  
  def stub_find(result)
    find_result = mock('find result', :to_a => result.map { |doc| doc.to_mongo }, :count => result.size)
    collection.stub!(:find).and_return(find_result)
  end
  
  def should_find(expected={}, result=[])
    selector, options = MongoModel::MongoOptions.new(self, expected).to_a
    find_result = mock('find result', :to_a => result.map { |doc| doc.to_mongo })
    collection.should_receive(:find).once.with(selector, options).and_return(find_result)
    yield
  end

  def should_not_find
    collection.should_not_receive(:find)
    yield
  end

  def should_count(expected={}, result=[])
    selector, options = MongoModel::MongoOptions.new(self, expected).to_a
    find_result = mock('find result', :count => result)
    collection.should_receive(:find).once.with(selector, options).and_return(find_result)
    yield
  end
  
  def should_not_count
    collection.should_not_receive(:find)
    yield
  end
end
