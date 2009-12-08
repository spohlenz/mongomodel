require 'active_support/core_ext/module/aliasing'

module MongoModel
  # Callbacks are hooks into the lifecycle of a MongoModel object that allow you to trigger logic
  # before or after an alteration of the object state. This can be used to make sure that associated and
  # dependent objects are deleted when +destroy+ is called (by overwriting +before_destroy+) or to massage attributes
  # before they're validated (by overwriting +before_validation+). As an example of the callbacks initiated, consider
  # the <tt>Document#save</tt> call for a new document:
  #
  # * (-) <tt>save</tt>
  # * (-) <tt>valid</tt>
  # * (1) <tt>before_validation</tt>
  # * (-) <tt>validate</tt>
  # * (-) <tt>validate_on_create</tt>
  # * (2) <tt>after_validation</tt>
  # * (3) <tt>before_save</tt>
  # * (4) <tt>before_create</tt>
  # * (-) <tt>create</tt>
  # * (5) <tt>after_create</tt>
  # * (6) <tt>after_save</tt>
  #
  # That's a total of eight callbacks, which gives you immense power to react and prepare for each state in the
  # MongoModel lifecycle. The sequence for calling <tt>Document#save</tt> for an existing record is similar, except that each 
  # <tt>_on_create</tt> callback is replaced by the corresponding <tt>_on_update</tt> callback.
  #
  # Examples:
  #   class CreditCard < MongoModel::Document
  #     # Strip everything but digits, so the user can specify "555 234 34" or
  #     # "5552-3434" or both will mean "55523434"
  #     def before_validation_on_create
  #       self.number = number.gsub(/[^0-9]/, "") if number?
  #     end
  #   end
  #
  #   class Subscription < MongoModel::Document
  #     before_create :record_signup
  #
  #     private
  #       def record_signup
  #         self.signed_up_on = Date.today
  #       end
  #   end
  #
  # == Inheritable callback queues
  #
  # Besides the overwritable callback methods, it's also possible to register callbacks through the use of the callback macros.
  # Their main advantage is that the macros add behavior into a callback queue that is kept intact down through an inheritance
  # hierarchy. Example:
  #
  #   class Topic < MongoModel::Document
  #     before_destroy :destroy_author
  #   end
  #
  #   class Reply < Topic
  #     before_destroy :destroy_readers
  #   end
  #
  # Now, when <tt>Topic#destroy</tt> is run only +destroy_author+ is called. When <tt>Reply#destroy</tt> is run, both +destroy_author+ and
  # +destroy_readers+ are called. Contrast this to the situation where we've implemented the save behavior through overwriteable
  # methods:
  #
  #   class Topic < MongoModel::Document
  #     def before_destroy() destroy_author end
  #   end
  #
  #   class Reply < Topic
  #     def before_destroy() destroy_readers end
  #   end
  #
  # In that case, <tt>Reply#destroy</tt> would only run +destroy_readers+ and _not_ +destroy_author+. So, use the callback macros when
  # you want to ensure that a certain callback is called for the entire hierarchy, and use the regular overwriteable methods
  # when you want to leave it up to each descendant to decide whether they want to call +super+ and trigger the inherited callbacks.
  #
  # *IMPORTANT:* In order for inheritance to work for the callback queues, you must specify the callbacks before specifying the
  # associations. Otherwise, you might trigger the loading of a child before the parent has registered the callbacks and they won't
  # be inherited.
  #
  # == Types of callbacks
  #
  # There are four types of callbacks accepted by the callback macros: Method references (symbol), callback objects,
  # inline methods (using a proc), and inline eval methods (using a string). Method references and callback objects are the
  # recommended approaches, inline methods using a proc are sometimes appropriate (such as for creating mix-ins), and inline
  # eval methods are deprecated.
  #
  # The method reference callbacks work by specifying a protected or private method available in the object, like this:
  #
  #   class Topic < MongoModel::Document
  #     before_destroy :delete_parents
  #
  #     private
  #       def delete_parents
  #         self.class.delete_all "parent_id = #{id}"
  #       end
  #   end
  #
  # The callback objects have methods named after the callback called with the record as the only parameter, such as:
  #
  #   class BankAccount < MongoModel::Document
  #     before_save      EncryptionWrapper.new
  #     after_save       EncryptionWrapper.new
  #     after_initialize EncryptionWrapper.new
  #   end
  #
  #   class EncryptionWrapper
  #     def before_save(doc)
  #       doc.credit_card_number = encrypt(doc.credit_card_number)
  #     end
  #
  #     def after_save(doc)
  #       doc.credit_card_number = decrypt(doc.credit_card_number)
  #     end
  #
  #     alias_method :after_load, :after_save
  #
  #     private
  #       def encrypt(value)
  #         # Secrecy is committed
  #       end
  #
  #       def decrypt(value)
  #         # Secrecy is unveiled
  #       end
  #   end
  #
  # So you specify the object you want messaged on a given callback. When that callback is triggered, the object has
  # a method by the name of the callback messaged. You can make these callbacks more flexible by passing in other
  # initialization data such as the name of the attribute to work with:
  #
  #   class BankAccount < MongoModel::Document
  #     before_save      EncryptionWrapper.new("credit_card_number")
  #     after_save       EncryptionWrapper.new("credit_card_number")
  #     after_initialize EncryptionWrapper.new("credit_card_number")
  #   end
  #
  #   class EncryptionWrapper
  #     def initialize(attribute)
  #       @attribute = attribute
  #     end
  #
  #     def before_save(doc)
  #       doc.send("#{@attribute}=", encrypt(doc.send("#{@attribute}")))
  #     end
  #
  #     def after_save(record)
  #       doc.send("#{@attribute}=", decrypt(doc.send("#{@attribute}")))
  #     end
  #
  #     alias_method :after_load, :after_save
  #
  #     private
  #       def encrypt(value)
  #         # Secrecy is committed
  #       end
  #
  #       def decrypt(value)
  #         # Secrecy is unveiled
  #       end
  #   end
  #
  # The callback macros usually accept a symbol for the method they're supposed to run, but you can also pass a "method string",
  # which will then be evaluated within the binding of the callback. Example:
  #
  #   class Topic < MongoModel::Document
  #     before_destroy 'self.class.delete_all "parent_id = #{id}"'
  #   end
  #
  # Notice that single quotes (') are used so the <tt>#{id}</tt> part isn't evaluated until the callback is triggered. Also note that these
  # inline callbacks can be stacked just like the regular ones:
  #
  #   class Topic < MongoModel::Document
  #     before_destroy 'self.class.delete_all "parent_id = #{id}"',
  #                    'puts "Evaluated after parents are destroyed"'
  #   end
  #
  # == The +after_find+ and +after_initialize+ exceptions
  #
  # Because +after_find+ and +after_initialize+ are called for each object found and instantiated by find, we've had
  # to implement a simple performance constraint (50% more speed on a simple test case). Unlike all the other callbacks, +after_find+ and
  # +after_initialize+ will only be run if an explicit implementation is defined (<tt>def after_find</tt>). In that case, all of the
  # callback types will be called.
  #
  # == <tt>before_validation*</tt> returning statements
  #
  # If the returning value of a +before_validation+ callback can be evaluated to +false+, the process will be aborted and <tt>Document#save</tt> will return +false+.
  # If Document#save! is called it will raise a MongoModel::DocumentInvalid exception.
  # Nothing will be appended to the errors object.
  #
  # == Canceling callbacks
  #
  # If a <tt>before_*</tt> callback returns +false+, all the later callbacks and the associated action are cancelled. If an <tt>after_*</tt> callback returns
  # +false+, all the later callbacks are cancelled. Callbacks are generally run in the order they are defined, with the exception of callbacks
  # defined as methods on the model, which are called last.
  module Callbacks
    extend ActiveSupport::Concern
    
    include ActiveSupport::Callbacks

    CALLBACKS = [
      :after_initialize, :after_find, :before_validation, :after_validation,
      :before_save, :around_save, :after_save, :before_create, :around_create,
      :after_create, :before_update, :around_update, :after_update,
      :before_destroy, :around_destroy, :after_destroy
    ]

    included do
      [:initialize, :valid?].each do |method|
        alias_method_chain method, :callbacks
      end
      
      define_callbacks :initialize, :find, :save, :create, :update, :destroy,
                       :validation, :terminator => "result == false", :scope => [:kind, :name]
    end
    
    module ClassMethods
      def after_initialize(*args, &block)
        options = args.extract_options!
        options[:prepend] = true
        set_callback(:initialize, :after, *(args << options), &block)
      end

      def after_find(*args, &block)
        options = args.extract_options!
        options[:prepend] = true
        set_callback(:find, :after, *(args << options), &block)
      end

      [:save, :create, :update, :destroy].each do |callback|
        module_eval <<-CALLBACKS, __FILE__, __LINE__
          def before_#{callback}(*args, &block)
            set_callback(:#{callback}, :before, *args, &block)
          end

          def around_#{callback}(*args, &block)
            set_callback(:#{callback}, :around, *args, &block)
          end

          def after_#{callback}(*args, &block)
            options = args.extract_options!
            options[:prepend] = true
            options[:if] = Array(options[:if]) << "!halted && value != false"
            set_callback(:#{callback}, :after, *(args << options), &block)
          end
        CALLBACKS
      end

      def before_validation(*args, &block)
        options = args.extract_options!
        if options[:on]
          options[:if] = Array(options[:if])
          options[:if] << "@_on_validate == :#{options[:on]}"
        end
        set_callback(:validation, :before, *(args << options), &block)
      end

      def after_validation(*args, &block)
        options = args.extract_options!
        options[:if] = Array(options[:if])
        options[:if] << "!halted"
        options[:if] << "@_on_validate == :#{options[:on]}" if options[:on]
        options[:prepend] = true
        set_callback(:validation, :after, *(args << options), &block)
      end
    end
    
    def initialize_with_callbacks(*args, &block) #:nodoc:
      initialize_without_callbacks(*args, &block)
      run_callbacks(:initialize)
    end
    
    def valid_with_callbacks? #:nodoc:
      @_on_validate = new_record? ? :create : :update
      run_callbacks(:validation) do
        valid_without_callbacks?
      end
    end
    
    def run_callbacks(kind, *args, &block)
      if block_given?
        embedded_callbacks = nest_embedded_callbacks(kind, *args, &block)
        super(kind, *args, &embedded_callbacks)
      else
        super(kind, *args)
        embedded_documents.each { |doc| doc.run_callbacks(kind, *args) } unless kind == :initialize
      end
    end
  
  private
    def nest_embedded_callbacks(kind, *args, &block)
      embedded_documents.inject(block) do |block, doc|
        Proc.new { doc.run_callbacks(kind, *args, &block) }
      end
    end
  end
end
