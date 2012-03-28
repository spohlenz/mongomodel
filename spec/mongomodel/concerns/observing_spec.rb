require 'spec_helper'

module MongoModel
  specs_for(Observer) do
  	describe "observing" do
  		define_class(:TestDocument, Document) do
  			property :title, String  			
  		end

  		define_class(:TestObserver, Observer) do
  			observe :test_document

        def callback(&callback)
          @callback = callback
        end

  			def after_save(model)
          @callback.call(model) unless @callback.nil?
  			end
  		end

      let(:doc) { TestDocument.new }      
      subject { doc }

      it "should have an #instance method to access the observer singleton" do
      	TestObserver.should be_respond_to :instance
        TestObserver.instance.should eq TestObserver.instance
      end

      # There's probably a better way to do this with mock objects, etc.
      it "should invoke the TestObserver singleton's after_save method after saving" do
        doc.title = 'Foo'
        called = false
        TestObserver.instance.callback do |model|
          doc.should eq model
          model.title.should eq 'Foo'
          called = true
        end        

        doc.save
        called.should eq true
      end
  	end
  end
end