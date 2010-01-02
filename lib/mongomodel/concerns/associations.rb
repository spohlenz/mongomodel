module MongoModel
  module Associations
    extend ActiveSupport::Concern
    
    def associations
      @_associations ||= self.class.associations.inject({}) do |result, (name, association)|
        result[name] = association.for(self)
        result
      end
    end
    
    module ClassMethods
      def belongs_to(name, options={})
        associations[name] = create_association(BelongsTo, name, options)
      end
    
      def associations
        read_inheritable_attribute(:associations) || write_inheritable_attribute(:associations, {})
      end
    
    private
      def create_association(type, name, options={})
        type.new(name, options).define(self)
      end
    end
  end
end



#
# belongs_to :user
#    => property :user_id
# belongs_to :author, :class_name => 'User'
#    => property :author_id
# belongs_to :commentable, :polymorphic => true
#    => property :commentable_id
#    => property :commentable_type
#

#
# has_many :contributors, :class_name => 'User', :foreign_key => :publication_id
# has_many :comments, :as => :commentable
# has_many :roles
#




#
# Documents and EmbeddedDocuments can:
#   - belong to any Document
#   - have many Documents by ids
#
# Documents can also:
#   - have many Documents by foreign key
#

# class Author < Document; end
# 
# class Comment < Document
#   # Creates properties :commentable_id and :commentable_type
#   belongs_to :commentable, :polymorphic => true
# end
# 
# class Page < EmbeddedDocument
#   # Creates property :editor_id
#   belongs_to :editor, :class => 'Author'
#   
#   # Creates property :related_article_ids
#   has_many :related_articles, :class => 'Article'
#   
#   # Polymorphic association, uses commentable_id/commentable_type on Comment class
#   has_many :comments, :as => :commentable
# end
# 
# class Article < Document
#   # Creates property :author_id
#   belongs_to :author
#   
#   # Creates property :recommended_by_ids
#   has_many :recommended_by, :by => :ids, :class => 'Author'
#   
#   # Creates property :parent_article_id
#   belongs_to :parent_article, :class => 'Article'
#   # Uses parent_article_id property on referenced class
#   has_many :child_articles, :by => :foreign_key, :foreign_key => :parent_article_id, :class => 'Article'
# end
