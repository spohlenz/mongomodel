require 'spec_helper'

# Specs ported from ActiveModel::Lint::Tests
#
# These tests do not attempt to determine the semantic correctness of the
# returned values. For instance, you could implement valid? to always
# return true, and the tests would pass. It is up to you to ensure that
# the values are semantically meaningful.
#
# Objects you pass in are expected to return a compliant object from a
# call to to_model. It is perfectly fine for to_model to return self.
module MongoModel
  specs_for(Document, EmbeddedDocument) do
    define_class(:TestModel, described_class)
    
    subject { TestModel.new.to_model }
    
    # == Responds to <tt>to_key</tt>
    #
    # Returns an Enumerable of all (primary) key attributes
    # or nil if model.persisted? is false
    it { should respond_to(:to_key) }
    
    specify "to_key should return nil if subject.persisted? is false" do
      subject.stub!(:persisted?).and_return(false)
      subject.to_key.should be_nil
    end
    
    # == Responds to <tt>to_param</tt>
    #
    # Returns a string representing the object's key suitable for use in URLs
    # or nil if model.persisted? is false.
    #
    # Implementers can decide to either raise an exception or provide a default
    # in case the record uses a composite primary key. There are no tests for this
    # behavior in lint because it doesn't make sense to force any of the possible
    # implementation strategies on the implementer. However, if the resource is
    # not persisted?, then to_param should always return nil.
    it { should respond_to(:to_param) }
    
    specify "to_param should return nil if subject.persisted? is false" do
      subject.stub!(:to_key).and_return([1])
      subject.stub!(:persisted?).and_return(false)
      subject.to_param.should be_nil
    end
    
    # == Responds to <tt>valid?</tt>
    #
    # Returns a boolean that specifies whether the object is in a valid or invalid
    # state.
    it { should respond_to_boolean(:valid?) }
    
    # == Responds to <tt>persisted?</tt>
    #
    # Returns a boolean that specifies whether the object has been persisted yet.
    # This is used when calculating the URL for an object. If the object is
    # not persisted, a form for that object, for instance, will be POSTed to the
    # collection. If it is persisted, a form for the object will put PUTed to the
    # URL for the object.
    it { should respond_to_boolean(:persisted?) }
    
    # == Naming
    #
    # Model.model_name must returns a string with some convenience methods as
    # :human and :partial_path. Check ActiveModel::Naming for more information.
    #
    specify "the model class should respond to model_name" do
      subject.class.should respond_to(:model_name)
    end
    
    it "should return strings for model_name" do
      model_name = subject.class.model_name
      model_name.should be_a_kind_of(String)
      model_name.human.should be_a_kind_of(String)
      model_name.partial_path.should be_a_kind_of(String)
      model_name.singular.should be_a_kind_of(String)
      model_name.plural.should be_a_kind_of(String)
    end
    
    # == Errors Testing
    # 
    # Returns an object that has :[] and :full_messages defined on it. See below
    # for more details.
    describe "errors" do
      it { should respond_to(:errors) }
      
      # Returns an Array of Strings that are the errors for the attribute in
      # question. If localization is used, the Strings should be localized
      # for the current locale. If no error is present, this method should
      # return an empty Array.
      describe "#[]" do
        it "should return an Array" do
          subject.errors[:hello].should be_an(Array)
        end
      end
      
      # Returns an Array of all error messages for the object. Each message
      # should contain information about the field, if applicable.
      describe "#full_messages" do
        it "should return an Array" do
          subject.errors.full_messages.should be_an(Array)
        end
      end
    end
  end
end
