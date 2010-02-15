require 'spec_helper'

# Specs ported from ActiveModel::Lint::Tests
module MongoModel
  specs_for(Document, EmbeddedDocument) do
    define_class(:TestModel, described_class)
    
    subject { TestModel.new.to_model }
    
    # valid?
    # ------
    #
    # Returns a boolean that specifies whether the object is in a valid or invalid
    # state.
    it { should respond_to_boolean(:valid?) }

    # new_record?
    # -----------
    #
    # Returns a boolean that specifies whether the object has been persisted yet.
    # This is used when calculating the URL for an object. If the object is
    # not persisted, a form for that object, for instance, will be POSTed to the
    # collection. If it is persisted, a form for the object will put PUTed to the
    # URL for the object.
    it { should respond_to_boolean(:new_record?) }
    it { should respond_to_boolean(:destroyed?) }
    
    # errors
    # ------
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
    
    describe "#model_name" do
      it "should return an ActiveModel::Name object" do
        TestModel.model_name.should == ActiveModel::Name.new(mock('TestModel class', :name => 'TestModel'))
      end
    end
  end
end
