require 'spec_helper'

module MongoModel
  specs_for(Document) do
    describe "observing" do
      define_class(:TestDocument, described_class)
      define_class(:TestObserver, Observer) do
        observe :test_document
        
        attr_accessor :callback

        def after_save(model)
          @callback.call(model) unless @callback.nil?
        end
      end

      subject { TestDocument.new }

      it "has an #instance method to access the observer singleton" do
        TestObserver.instance.should eq(TestObserver.instance)
      end
      
      it "invokes the TestObserver singleton's after_save method after saving" do
        callback = stub
        callback.should_receive(:call).with(subject)
        
        TestObserver.instance.callback = callback
        subject.save
      end
    end
  end
end
