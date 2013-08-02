require 'rspec/mocks'

module DocumentFinderStubs
  include RSpec::Mocks::ExampleMethods
  
  def stub_find(result)
    find_result = double('find result', :to_a => result.map { |doc| doc.to_mongo }, :count => result.size).as_null_object
    collection.stub(:find).and_return(find_result)
  end
  
  def should_find(expected={}, result=[])
    selector, options = MongoModel::MongoOptions.new(self, expected).to_a
    find_result = double('find result', :to_a => result.map { |doc| doc.to_mongo }).as_null_object
    collection.should_receive(:find).once.with(selector, options).and_return(find_result)
    yield if block_given?
  end

  def should_not_find
    collection.should_not_receive(:find)
    yield if block_given?
  end

  def should_count(expected={}, result=[])
    selector, options = MongoModel::MongoOptions.new(self, expected).to_a
    find_result = double('find result', :count => result).as_null_object
    collection.should_receive(:find).once.with(selector, options).and_return(find_result)
    yield if block_given?
  end
  
  def should_not_count
    collection.should_not_receive(:find)
    yield if block_given?
  end
  
  def stub_delete
    collection.stub(:remove)
  end
  
  def should_delete(conditions={})
    selector, options = MongoModel::MongoOptions.new(self, :conditions => conditions).to_a
    collection.should_receive(:remove).once.with(selector, options)
    yield if block_given?
  end
  
  def should_update(conditions={}, updates={})
    selector, options = MongoModel::MongoOptions.new(self, :conditions => conditions).to_a
    collection.should_receive(:update).once.with(selector, { "$set" => updates }, { :multi => true })
    yield if block_given?
  end
end
