require 'spec_helper'

module MongoModel
  specs_for(Document) do
    describe "callbacks" do
      define_class(:CallbackTestDocument, Document) do
        class << self
          def callback_string(callback_method)
            "history << [#{callback_method.to_sym.inspect}, :string]"
          end

          def callback_proc(callback_method)
            Proc.new { |model| model.history << [callback_method, :proc] }
          end

          def define_callback_method(callback_method)
            define_method("#{callback_method}_method") do |model|
              model.history << [callback_method, :method]
            end
          end

          def callback_object(callback_method)
            klass = Class.new
            klass.send(:define_method, callback_method) do |model|
              model.history << [callback_method, :object]
            end
            klass.new
          end
        end

        MongoModel::Callbacks::CALLBACKS.each do |callback_method|
          next if callback_method.to_s =~ /^around_/
          define_callback_method(callback_method)
          send(callback_method, callback_string(callback_method))
          send(callback_method, callback_proc(callback_method))
          send(callback_method, callback_object(callback_method))
          send(callback_method) { |model| model.history << [callback_method, :block] }
        end
        
        def history
          @history ||= []
        end
      end
      
      it "should run each type of callback when initializing" do
        instance = CallbackTestDocument.new
        instance.should run_callbacks(:after_initialize)
      end
  
      it "should run each type of callback on find" do
        doc = CallbackTestDocument.create!
    
        instance = CallbackTestDocument.find(doc.id)
        instance.should run_callbacks(:after_initialize, :after_find)
      end
  
      it "should run each type of callback when validating a new document" do
        instance = CallbackTestDocument.new
        instance.valid?
        instance.should run_callbacks(:after_initialize, :before_validation, :after_validation)
      end
  
      it "should run each type of callback when validating an existing document" do
        doc = CallbackTestDocument.create!
    
        instance = CallbackTestDocument.find(doc.id)
        instance.valid?
        instance.should run_callbacks(:after_initialize, :after_find, :before_validation, :after_validation)
      end
  
      it "should run each type of callback when creating a document" do
        instance = CallbackTestDocument.create!
        instance.should run_callbacks(:after_initialize, :before_validation, :after_validation, :before_save, :before_create, :after_create, :after_save)
      end
  
      it "should run each type of callback when saving an existing document" do
        doc = CallbackTestDocument.create!
    
        instance = CallbackTestDocument.find(doc.id)
        instance.save
        instance.should run_callbacks(:after_initialize, :after_find, :before_validation, :after_validation, :before_save, :before_update, :after_update, :after_save)
      end
  
      it "should run each type of callback when destroying a document" do
        doc = CallbackTestDocument.create!
    
        instance = CallbackTestDocument.find(doc.id)
        instance.destroy
        instance.should run_callbacks(:after_initialize, :after_find, :before_destroy, :after_destroy)
      end
  
      it "should not run destroy callbacks when deleting a document" do
        doc = CallbackTestDocument.create!
    
        instance = CallbackTestDocument.find(doc.id)
        instance.delete
        instance.should run_callbacks(:after_initialize, :after_find)
      end
      
      [ :before_save, :before_create ].each do |callback|
        context "#{callback} callback return false" do
          define_class(:CallbackTestDocument, Document) do
            send(callback) { false }
          end
        
          subject { CallbackTestDocument.new }
        
          describe "#save" do
            it "should return false" do
              subject.save.should be_false
            end
          end
        
          describe "#save!" do
            it "should raise a MongoModel::DocumentNotSaved exception" do
              lambda { subject.save! }.should raise_error(MongoModel::DocumentNotSaved)
            end
          end
        end
      end
    end
  end
  
  specs_for(EmbeddedDocument) do
    
  end
end
