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
# many :pages
# many :contributors, :class_name => 'User', :foreign_key => :publication_id
# many :comments, :as => :commentable
# many :roles
#
