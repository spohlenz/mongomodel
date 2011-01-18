require 'spec_helper'

module MongoModel
  specs_for(Document) do
    describe "collection modifiers" do
      define_class(:Post, Document) do
        property :hits, Integer
        property :available, Integer
        property :tags, Array
      end
      
      let(:collection) { Post.collection }
      subject { Post }
      
      def self.should_update_collection(expression, &block)
        it "should update the collection" do
          collection.should_receive(:update).with(selector, expression, :multi => true)
          instance_eval(&block)
        end
      end
      
      context "unscoped" do
        let(:selector) { {} }
        
        describe ".increase!" do
          should_update_collection('$inc' => { 'hits' => 1, 'available' => -1 }) do
            subject.increase!(:hits => 1, :available => -1)
          end
        end
      
        describe ".set!" do
          should_update_collection('$set' => { 'hits' => 20, 'available' => 100 }) do
            subject.set!(:hits => 20, :available => 100)
          end
        end
        
        describe ".unset!" do
          should_update_collection('$unset' => { 'hits' => 1, 'available' => 1 }) do
            subject.unset!(:hits, :available)
          end
        end
        
        describe ".push!" do
          should_update_collection('$push' => { 'tags' => 'abc' }) do
            subject.push!(:tags => 'abc')
          end
        end
        
        describe ".push_all!" do
          should_update_collection('$pushAll' => { 'tags' => ['xxx', 'yyy', 'zzz'] }) do
            subject.push_all!(:tags => ['xxx', 'yyy', 'zzz'])
          end
        end
        
        describe ".add_to_set!" do
          should_update_collection('$addToSet' => { 'tags' => 'xxx' }) do
            subject.add_to_set!(:tags => 'xxx')
          end
        end
        
        describe ".pull!" do
          should_update_collection('$pull' => { 'tags' => 'abc' }) do
            subject.pull!(:tags => 'abc')
          end
        end
        
        describe ".pull_all!" do
          should_update_collection('$pullAll' => { 'tags' => ['xxx', 'yyy', 'zzz'] }) do
            subject.pull_all!(:tags => ['xxx', 'yyy', 'zzz'])
          end
        end
        
        describe ".pop!" do
          should_update_collection('$pop' => { 'tags' => 1 }) do
            subject.pop!(:tags)
          end
        end
        
        describe ".shift!" do
          should_update_collection('$pop' => { 'tags' => -1 }) do
            subject.shift!(:tags)
          end
        end
        
        describe ".rename!" do
          should_update_collection('$rename' => { 'tags' => :tag_collection }) do
            subject.rename!(:tags => :tag_collection)
          end
        end
      end
    end
  end
end
