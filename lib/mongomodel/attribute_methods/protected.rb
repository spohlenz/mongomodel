module MongoModel
  module AttributeMethods
    module Protected
        extend ActiveSupport::Concern

        module ClassMethods
          def property(name, *args, &block)#:nodoc:
            options = args.extract_options!

            super(name, *args << options, &block)

            attr_protected(name) if options[:protected]
            attr_accessible(name) if options[:accessible]
          end

          # Attributes named in this macro are protected from mass-assignment,
          # such as <tt>new(attributes)</tt>,
          # <tt>update_attributes(attributes)</tt>, or
          # <tt>attributes=(attributes)</tt>.
          #
          # Mass-assignment to these attributes will simply be ignored, to assign
          # to them you can use direct writer methods. This is meant to protect
          # sensitive attributes from being overwritten by malicious users
          # tampering with URLs or forms.
          #
          #   class Customer < Recliner::Document
          #     attr_protected :credit_rating
          #   end
          #
          #   customer = Customer.new("name" => David, "credit_rating" => "Excellent")
          #   customer.credit_rating # => nil
          #   customer.attributes = { "description" => "Jolly fellow", "credit_rating" => "Superb" }
          #   customer.credit_rating # => nil
          #
          #   customer.credit_rating = "Average"
          #   customer.credit_rating # => "Average"
          #
          # To start from an all-closed default and enable attributes as needed,
          # have a look at +attr_accessible+.
          #
          # If the access logic of your application is richer you can use <tt>Hash#except</tt>
          # or <tt>Hash#slice</tt> to sanitize the hash of parameters before they are
          # passed to Recliner.
          # 
          # For example, it could be the case that the list of protected attributes
          # for a given model depends on the role of the user:
          #
          #   # Assumes plan_id is not protected because it depends on the role.
          #   params[:account] = params[:account].except(:plan_id) unless admin?
          #   @account.update_attributes(params[:account])
          #
          # Note that +attr_protected+ is still applied to the received hash. Thus,
          # with this technique you can at most _extend_ the list of protected
          # attributes for a particular mass-assignment call.
          def attr_protected(*attrs)
            write_inheritable_attribute(:attr_protected, attrs.map { |a| a.to_s } + protected_attributes)
          end

          # Specifies a white list of model attributes that can be set via
          # mass-assignment, such as <tt>new(attributes)</tt>,
          # <tt>update_attributes(attributes)</tt>, or
          # <tt>attributes=(attributes)</tt>
          #
          # This is the opposite of the +attr_protected+ macro: Mass-assignment
          # will only set attributes in this list, to assign to the rest of
          # attributes you can use direct writer methods. This is meant to protect
          # sensitive attributes from being overwritten by malicious users
          # tampering with URLs or forms. If you'd rather start from an all-open
          # default and restrict attributes as needed, have a look at
          # +attr_protected+.
          #
          #   class Customer < Recliner::Document
          #     attr_accessible :name, :nickname
          #   end
          #
          #   customer = Customer.new(:name => "David", :nickname => "Dave", :credit_rating => "Excellent")
          #   customer.credit_rating # => nil
          #   customer.attributes = { :name => "Jolly fellow", :credit_rating => "Superb" }
          #   customer.credit_rating # => nil
          #
          #   customer.credit_rating = "Average"
          #   customer.credit_rating # => "Average"
          #
          # If the access logic of your application is richer you can use <tt>Hash#except</tt>
          # or <tt>Hash#slice</tt> to sanitize the hash of parameters before they are
          # passed to Recliner.
          # 
          # For example, it could be the case that the list of accessible attributes
          # for a given model depends on the role of the user:
          #
          #   # Assumes plan_id is accessible because it depends on the role.
          #   params[:account] = params[:account].except(:plan_id) unless admin?
          #   @account.update_attributes(params[:account])
          #
          # Note that +attr_accessible+ is still applied to the received hash. Thus,
          # with this technique you can at most _narrow_ the list of accessible
          # attributes for a particular mass-assignment call.
          def attr_accessible(*attrs)
            write_inheritable_attribute(:attr_accessible, attrs.map { |a| a.to_s } + accessible_attributes)
          end

          # Returns an array of all the attributes that have been protected from mass-assignment.
          def protected_attributes
            read_inheritable_attribute(:attr_protected) || []
          end

          # Returns an array of all the attributes that have been made accessible to mass-assignment.
          def accessible_attributes
            read_inheritable_attribute(:attr_accessible) || []
          end
        end

        def attributes=(attrs)#:nodoc:
          super(remove_protected_attributes(attrs))
        end

      private
        def remove_protected_attributes(attrs)
          if self.class.accessible_attributes.empty?
            attrs.reject { |k, v| self.class.protected_attributes.include?(k.to_s) }
          else
            attrs.reject { |k, v| !self.class.accessible_attributes.include?(k.to_s) }
          end
        end
    end
  end
end
