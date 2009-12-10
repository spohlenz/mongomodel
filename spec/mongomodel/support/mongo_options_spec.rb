require 'spec_helper'

module MongoModel
  describe MongoOptions do
    define_class(:TestDocument, Document)
    
    shared_examples_for "options without conditions" do
      it "should have an empty selector hash" do
        subject.selector.should == {}
      end
    end
    
    shared_examples_for "options with conditions only" do
      it "should have an empty options hash" do
        subject.options.should == {}
      end
    end
    
    context "with blank options" do
      subject { MongoOptions.new(TestDocument) }
      
      it_should_behave_like "options without conditions"
      
      it "should have an empty options hash" do
        subject.options.should == {}
      end
    end
    
    context "with basic conditions" do
      subject { MongoOptions.new(TestDocument, :conditions => { :foo => 'bar' }) }
      
      it_should_behave_like "options with conditions only"
      
      it "should include the conditions in the selector" do
        subject.selector.should == { :foo => 'bar' }
      end
    end
    
    context "with conditions using an operator" do
      subject { MongoOptions.new(TestDocument, :conditions => { :age.gt => 10 }) }
      
      it_should_behave_like "options with conditions only"
      
      it "should include the expanded conditions in the selector" do
        subject.selector.should == { :age => { '$gt' => 10 } }
      end
    end
    
    context "with conditions using a property" do
      subject { MongoOptions.new(TestDocument, :conditions => { :id => '123' }) }
      
      it_should_behave_like "options with conditions only"
      
      it "should use the property as value in the selector" do
        subject.selector.should == { '_id' => '123' }
      end
    end
    
    context "with basic options (no conditions or order)" do
      subject { MongoOptions.new(TestDocument, :offset => 20, :limit => 10, :select => [ :foo, :bar ]) }
      
      it_should_behave_like "options without conditions"
      
      it "should include converted options in options hash" do
        subject.options.should == { :skip => 20, :limit => 10, :fields => [ :foo, :bar ]}
      end
    end
    
    context "with string order" do
      subject { MongoOptions.new(TestDocument, :order => 'foo DESC') }
      
      it_should_behave_like "options without conditions"
      
      it "should convert order to sort in options hash" do
        subject.options.should == { :sort => [ ['foo', :descending] ] }
      end
    end
    
    context "with symbol order" do
      subject { MongoOptions.new(TestDocument, :order => :bar) }
      
      it_should_behave_like "options without conditions"
      
      it "should convert order to sort in options hash" do
        subject.options.should == { :sort => [ ['bar', :ascending] ]}
      end
    end
    
    context "with symbol(asc) order" do
      subject { MongoOptions.new(TestDocument, :order => :bar.asc) }
      
      it_should_behave_like "options without conditions"
      
      it "should convert order to sort in options hash" do
        subject.options.should == { :sort => [ ['bar', :ascending] ]}
      end
    end
    
    context "with multiple orders in array" do
      subject { MongoOptions.new(TestDocument, :order => ['foo ASC', :bar.desc]) }
      
      it_should_behave_like "options without conditions"
      
      it "should convert order to sort in options hash" do
        subject.options.should == { :sort => [ ['foo', :ascending], ['bar', :descending]] }
      end
    end
    
    context "with multiple orders in string" do
      subject { MongoOptions.new(TestDocument, :order => 'foo DESC, baz') }
      
      it_should_behave_like "options without conditions"
      
      it "should convert order to sort in options hash" do
        subject.options.should == { :sort => [ ['foo', :descending], ['baz', :ascending] ] }
      end
    end
    
    context "with an order using a property" do
      subject { MongoOptions.new(TestDocument, :order => :id.desc) }
      
      it_should_behave_like "options without conditions"
      
      it "should use property as value as sort column" do
        subject.options.should == { :sort => [ ['_id', :descending] ] }
      end
    end
    
    context "with conditions and options" do
      subject { MongoOptions.new(TestDocument, :conditions => { :age => 18 }, :order => :id.desc, :limit => 5) }
      
      it "should use conditions for selector" do
        subject.selector.should == { :age => 18 }
      end
      
      it "should convert options" do
        subject.options.should == { :sort => [ ['_id', :descending] ], :limit => 5 }
      end
      
      it "should convert to array" do
        subject.to_a.should == [ subject.selector, subject.options ]
      end
    end
  end
  
  describe MongoOrder do
    def c(field, order)
      MongoOrder::Clause.new(field, order)
    end
    
    subject { MongoOrder.new(c(:name, :ascending), c(:age, :descending)) }
    
    it "should convert to string" do
      subject.to_s.should == "name ascending, age descending"
    end
    
    describe "#to_sort" do
      it "should convert to mongo sort array" do
        model = mock('model', :properties => mock('properties', :[] => nil))
        subject.to_sort(model).should == [['name', :ascending], ['age', :descending]]
      end
    end
    
    it "should be reversable" do
      subject.reverse.should == MongoOrder.new(c(:name, :descending), c(:age, :ascending))
    end
    
    it "should equal another order object with identical clauses" do
      subject.should == MongoOrder.new(c(:name, :ascending), c(:age, :descending))
    end
    
    it "should equal another order object with different clauses" do
      subject.should_not == MongoOrder.new(c(:name, :ascending))
      subject.should_not == MongoOrder.new(c(:age, :ascending), c(:name, :ascending))
    end
    
    describe "#parse" do
      it "should not change a MongoOrder" do
        MongoOrder.parse(subject).should == subject
      end
      
      it "should convert individual clause to MongoOrder" do
        MongoOrder.parse(c(:name, :ascending)).should == MongoOrder.new(c(:name, :ascending))
      end
      
      it "should convert symbol to MongoOrder" do
        MongoOrder.parse(:name).should == MongoOrder.new(c(:name, :ascending))
      end
      
      it "should convert array of clauses to MongoOrder" do
        MongoOrder.parse([c(:name, :ascending), c(:age, :descending)]).should == MongoOrder.new(c(:name, :ascending), c(:age, :descending))
      end
      
      it "should convert array of symbols to MongoOrder" do
        MongoOrder.parse([:name, :age]).should == MongoOrder.new(c(:name, :ascending), c(:age, :ascending))
      end
      
      it "should convert array of strings to MongoOrder" do
        MongoOrder.parse(['name ASC', 'age DESC']).should == MongoOrder.new(c(:name, :ascending), c(:age, :descending))
      end
      
      it "should convert string (no order specified) to MongoOrder" do
        MongoOrder.parse('name').should == MongoOrder.new(c(:name, :ascending))
      end
      
      it "should convert string (single order) to MongoOrder" do
        MongoOrder.parse('name DESC').should == MongoOrder.new(c(:name, :descending))
      end
      
      it "should convert string (multiple orders) to MongoOrder" do
        MongoOrder.parse('name DESC, age ASC').should == MongoOrder.new(c(:name, :descending), c(:age, :ascending))
      end
    end
  end
  
  describe MongoOrder::Clause do
    subject { MongoOrder::Clause.new(:name, :ascending) }
    
    it "should convert to string" do
      subject.to_s.should == "name ascending"
    end
    
    it "should equal another clause with the same field and order" do
      subject.should == MongoOrder::Clause.new(:name, :ascending)
    end
    
    it "should equal another clause with a different field or order" do
      subject.should_not == MongoOrder::Clause.new(:age, :ascending)
      subject.should_not == MongoOrder::Clause.new(:name, :descending)
    end
    
    it "should be reversable" do
      subject.reverse.should == MongoOrder::Clause.new(:name, :descending)
    end
    
    describe "#to_sort" do
      context "given property" do
        it "should use property as value to convert to mongo sort" do
          property = mock('property', :as => '_name')
          subject.to_sort(property).should == ['_name', :ascending]
        end
      end
      
      context "given nil" do
        it "should convert to mongo sort" do
          subject.to_sort(nil).should == ['name', :ascending]
        end
      end
    end
    
    describe "#parse" do
      let(:asc) { MongoOrder::Clause.new(:name, :ascending) }
      let(:desc) { MongoOrder::Clause.new(:name, :descending) }
      
      it "should create Clause from string (no order)" do
        MongoOrder::Clause.parse('name').should == asc
      end
      
      it "should create Clause from string (with order)" do
        MongoOrder::Clause.parse('name ASC').should == asc
        MongoOrder::Clause.parse('name asc').should == asc
        MongoOrder::Clause.parse('name ascending').should == asc
        MongoOrder::Clause.parse('name DESC').should == desc
        MongoOrder::Clause.parse('name desc').should == desc
        MongoOrder::Clause.parse('name descending').should == desc
      end
    end
  end
  
  describe MongoOperator do
    subject { MongoOperator.new(:age, :gt) }
    
    it "should convert to mongo selector" do
      subject.to_mongo_selector(14).should == { '$gt' => 14 }
    end
    
    it "should be equal to a MongoOperator with the same field and operator" do
      subject.should == MongoOperator.new(:age, :gt)
    end
    
    it "should not be equal to a MongoOperator with a different field/operator" do
      subject.should_not == MongoOperator.new(:age, :lte)
      subject.should_not == MongoOperator.new(:date, :gt)
    end
    
    it "should be created from symbol methods" do
      :age.gt.should == MongoOperator.new(:age, :gt)
      :date.lte.should == MongoOperator.new(:date, :lte)
    end
    
    it "should be equal within a hash" do
      { :age.gt => 10 }.should == { :age.gt => 10 }
    end
  end
end
