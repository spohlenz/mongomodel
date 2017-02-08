require 'spec_helper'

module MongoModel
  specs_for(EmbeddedDocument) do
    describe "callbacks on many embedded documents" do
      define_class(:ChildThingDocument, EmbeddedDocument) do
        include MongoModel::CallbackHelpers
        property :name, String
      end

      define_class(:ParentDocument, Document) do
        property :things, Collection[ChildThingDocument]
      end

      it "calls callbacks on all embedded documents when adding a new one" do
        parent = ParentDocument.create!
        parent.things = Collection[ChildThingDocument].new
        parent.things << ChildThingDocument.new(:name => "Thing One")
        parent.save!
        parent = ParentDocument.find(parent.id)
        parent.things << ChildThingDocument.new(:name => "Thing Two")
        parent.save!
      end
    end

    describe "callbacks" do
      define_class(:ChildDocument, EmbeddedDocument) do
        include MongoModel::CallbackHelpers
      end

      define_class(:ParentDocument, Document) do
        property :child, ChildDocument
      end

      let(:child) { ChildDocument.new }
      let(:parent) { ParentDocument.create!(:child => child) }

      it "runs each type of callback when initializing" do
        instance = ChildDocument.new
        instance.should run_callbacks(:after_initialize)
      end

      it "runs each type of callback on find" do
        instance = ParentDocument.find(parent.id).child
        instance.should run_callbacks(:after_initialize, :after_find)
      end

      it "runs each type of callback when validating a new document" do
        instance = ChildDocument.new
        instance.valid?
        instance.should run_callbacks(:after_initialize, :before_validation, :after_validation)
      end

      it "runs each type of callback when validating an existing document" do
        instance = ParentDocument.find(parent.id).child
        instance.valid?
        instance.should run_callbacks(:after_initialize, :after_find, :before_validation, :after_validation)
      end

      it "runs each type of callback when creating a document" do
        instance = ParentDocument.create!(:child => ChildDocument.new)
        instance.child.should run_callbacks(:after_initialize, :before_validation, :after_validation, :before_save, :before_create, :after_create, :after_save)
      end

      it "runs each type of callback when saving an existing document" do
        instance = ParentDocument.find(parent.id)
        instance.save
        instance.child.should run_callbacks(:after_initialize, :after_find, :before_validation, :after_validation, :before_save, :before_update, :after_update, :after_save)
      end

      it "runs each type of callback when destroying a document" do
        instance = ParentDocument.find(parent.id)
        instance.destroy
        instance.child.should run_callbacks(:after_initialize, :after_find, :before_destroy, :after_destroy)
      end

      it "does not run destroy callbacks when deleting a document" do
        instance = ParentDocument.find(parent.id)
        instance.delete
        instance.child.should run_callbacks(:after_initialize, :after_find)
      end
    end

    [ :before_save, :before_create ].each do |callback|
      context "#{callback} callback halts" do
        define_class(:ChildDocument, EmbeddedDocument) do
          if Gem::Version.new(ActiveSupport::VERSION::STRING) >= Gem::Version.new('5.0.0')
            send(callback) { throw :abort }
          else
            send(callback) { false }
          end
        end

        define_class(:ParentDocument, Document) do
          property :child, ChildDocument
        end

        let(:child) { ChildDocument.new }
        let(:parent) { ParentDocument.new(:child => child) }

        describe "#save" do
          it "returns false" do
            parent.save.should be false
          end
        end

        describe "#save!" do
          it "raises a MongoModel::DocumentNotSaved exception" do
            lambda { parent.save! }.should raise_error(MongoModel::DocumentNotSaved)
          end
        end
      end
    end
  end
end
