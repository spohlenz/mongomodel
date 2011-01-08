module MongoModel
  module DocumentExtensions
    module Updating
      extend ActiveSupport::Concern
      
      module ClassMethods
        # Post.increase!(:hits => 1, :available => -1)
        def increase!(args)
          collection_modifier_update('$inc', args)
        end

        # Post.set!(:hits => 0, :available => 100)
        def set!(args)
          collection_modifier_update('$set', args)
        end

        # Post.unset!(:hits, :available)
        def unset!(*args)
          values = args.each_with_object({}) {|key, hash| hash[key.to_s] = 1 }
          collection_modifier_update('$unset', values)
        end

        # Post.push!(:tags => 'xxx')
        def push!(args)
          collection_modifier_update('$push', args)
        end

        # Post.push_all!(:tags => ['xxx', 'yyy', 'zzz'])
        def push_all!(args)
          collection_modifier_update('$pushAll', args)
        end

        # Post.pull!(:tags => 'xxx')
        def pull!(args)
          collection_modifier_update('$pull', args)
        end

        # Post.pull_all!(:tags => ['xxx', 'yyy', 'zzz'])
        def pull_all!(args)
          collection_modifier_update('$pullAll', args)
        end

        # Post.pop!(:tags)
        def pop!(*args)
          values = args.each_with_object({}) {|key, hash| hash[key.to_s] = 1 }
          collection_modifier_update('$pop', values)
        end

        # Post.shift!(:tags, :data)
        def shift!(*args)
          values = args.each_with_object({}) {|key, hash| hash[key.to_s] = -1 }
          collection_modifier_update('$pop', values)
        end

        # requires mongodb 1.7.2
        # Post.rename!(:tags => :tag_collection)
        def rename!(args)
          collection_modifier_update('$rename', args)
        end

        private
        def collection_modifier_update(modifier, args)
          selector = MongoModel::MongoOptions.new(self, scoped.finder_options).selector
          collection.update(selector, {modifier => args.stringify_keys!}, :multi => true)
        end
      end

      module InstanceMethods
        def increase!(args)
          self.class.where(:id => id).increase!(args)
        end

        def set!(args)
          self.class.where(:id => id).set!(args)
        end

        def unset!(*args)
          self.class.where(:id => id).unset!(*args)
        end

        def push!(args)
          self.class.where(:id => id).push!(args)
        end

        def push_all!(args)
          self.class.where(:id => id).push_all!(args)
        end

        def pull!(args)
          self.class.where(:id => id).pull!(args)
        end

        def pull_all!(args)
          self.class.where(:id => id).pull_all!(args)
        end

        def pop!(*args)
          self.class.where(:id => id).pop!(*args)
        end

        def shift!(*args)
          self.class.where(:id => id).shift!(*args)
        end

        # requires mongodb 1.7.2
        def rename!(args)
          self.class.where(:id => id).rename!(args)
        end

      end
      
    end
  end
end