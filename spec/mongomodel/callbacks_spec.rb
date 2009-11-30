require 'spec_helper'

module MongoModel
  describe Document do
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

        # after_initialize and after_find are invoked only if instance methods have been defined.
        def after_initialize
        end

        def after_find
        end
      end
  
      it "should run each type of callback when initializing" do
        instance = CallbackTestDocument.new
        instance.history.should == [
          [ :after_initialize, :string ],
          [ :after_initialize, :proc   ],
          [ :after_initialize, :object ],
          [ :after_initialize, :block  ]
        ]
      end
  
      it "should run each type of callback on find" do
        doc = CallbackTestDocument.create!
    
        instance = CallbackTestDocument.find(doc.id)
        instance.history.should == [
          [ :after_initialize, :string ],
          [ :after_initialize, :proc   ],
          [ :after_initialize, :object ],
          [ :after_initialize, :block  ],
          [ :after_find,       :string ],
          [ :after_find,       :proc   ],
          [ :after_find,       :object ],
          [ :after_find,       :block  ]
        ]
      end
  
      it "should run each type of callback when validating a new document" do
        instance = CallbackTestDocument.new
        instance.valid?
        instance.history.should == [
          [ :after_initialize,  :string ],
          [ :after_initialize,  :proc   ],
          [ :after_initialize,  :object ],
          [ :after_initialize,  :block  ],
          [ :before_validation, :string ],
          [ :before_validation, :proc   ],
          [ :before_validation, :object ],
          [ :before_validation, :block  ],
          [ :after_validation,  :string ],
          [ :after_validation,  :proc   ],
          [ :after_validation,  :object ],
          [ :after_validation,  :block  ]
        ]
      end
  
      it "should run each type of callback when validating an existing document" do
        doc = CallbackTestDocument.create!
    
        instance = CallbackTestDocument.find(doc.id)
        instance.valid?
        instance.history.should == [
          [ :after_initialize,  :string ],
          [ :after_initialize,  :proc   ],
          [ :after_initialize,  :object ],
          [ :after_initialize,  :block  ],
          [ :after_find,        :string ],
          [ :after_find,        :proc   ],
          [ :after_find,        :object ],
          [ :after_find,        :block  ],
          [ :before_validation, :string ],
          [ :before_validation, :proc   ],
          [ :before_validation, :object ],
          [ :before_validation, :block  ],
          [ :after_validation,  :string ],
          [ :after_validation,  :proc   ],
          [ :after_validation,  :object ],
          [ :after_validation,  :block  ]
        ]
      end
  
      it "should run each type of callback when creating a document" do
        instance = CallbackTestDocument.create!
        instance.history.should == [
          [ :after_initialize,  :string ],
          [ :after_initialize,  :proc   ],
          [ :after_initialize,  :object ],
          [ :after_initialize,  :block  ],
          [ :before_validation, :string ],
          [ :before_validation, :proc   ],
          [ :before_validation, :object ],
          [ :before_validation, :block  ],
          [ :after_validation,  :string ],
          [ :after_validation,  :proc   ],
          [ :after_validation,  :object ],
          [ :after_validation,  :block  ],
          [ :before_save,       :string ],
          [ :before_save,       :proc   ],
          [ :before_save,       :object ],
          [ :before_save,       :block  ],
          [ :before_create,     :string ],
          [ :before_create,     :proc   ],
          [ :before_create,     :object ],
          [ :before_create,     :block  ],
          [ :after_create,      :string ],
          [ :after_create,      :proc   ],
          [ :after_create,      :object ],
          [ :after_create,      :block  ],
          [ :after_save,        :string ],
          [ :after_save,        :proc   ],
          [ :after_save,        :object ],
          [ :after_save,        :block  ]
        ]
      end
  
      it "should run each type of callback when saving an existing document" do
        doc = CallbackTestDocument.create!
    
        instance = CallbackTestDocument.find(doc.id)
        instance.save
        instance.history.should == [
          [ :after_initialize,  :string ],
          [ :after_initialize,  :proc   ],
          [ :after_initialize,  :object ],
          [ :after_initialize,  :block  ],
          [ :after_find,        :string ],
          [ :after_find,        :proc   ],
          [ :after_find,        :object ],
          [ :after_find,        :block  ],
          [ :before_validation, :string ],
          [ :before_validation, :proc   ],
          [ :before_validation, :object ],
          [ :before_validation, :block  ],
          [ :after_validation,  :string ],
          [ :after_validation,  :proc   ],
          [ :after_validation,  :object ],
          [ :after_validation,  :block  ],
          [ :before_save,       :string ],
          [ :before_save,       :proc   ],
          [ :before_save,       :object ],
          [ :before_save,       :block  ],
          [ :before_update,     :string ],
          [ :before_update,     :proc   ],
          [ :before_update,     :object ],
          [ :before_update,     :block  ],
          [ :after_update,      :string ],
          [ :after_update,      :proc   ],
          [ :after_update,      :object ],
          [ :after_update,      :block  ],
          [ :after_save,        :string ],
          [ :after_save,        :proc   ],
          [ :after_save,        :object ],
          [ :after_save,        :block  ]
        ]
      end
  
      it "should run each type of callback when destroying a document" do
        doc = CallbackTestDocument.create!
    
        instance = CallbackTestDocument.find(doc.id)
        instance.destroy
        instance.history.should == [
          [ :after_initialize,            :string ],
          [ :after_initialize,            :proc   ],
          [ :after_initialize,            :object ],
          [ :after_initialize,            :block  ],
          [ :after_find,                  :string ],
          [ :after_find,                  :proc   ],
          [ :after_find,                  :object ],
          [ :after_find,                  :block  ],
          [ :before_destroy,              :string ],
          [ :before_destroy,              :proc   ],
          [ :before_destroy,              :object ],
          [ :before_destroy,              :block  ],
          [ :after_destroy,               :string ],
          [ :after_destroy,               :proc   ],
          [ :after_destroy,               :object ],
          [ :after_destroy,               :block  ]
        ]
      end
  
      it "should not run destroy callbacks when deleting a document" do
        doc = CallbackTestDocument.create!
    
        instance = CallbackTestDocument.find(doc.id)
        instance.delete
        instance.history.should == [
          [ :after_initialize,            :string ],
          [ :after_initialize,            :proc   ],
          [ :after_initialize,            :object ],
          [ :after_initialize,            :block  ],
          [ :after_find,                  :string ],
          [ :after_find,                  :proc   ],
          [ :after_find,                  :object ],
          [ :after_find,                  :block  ]
        ]
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
end
