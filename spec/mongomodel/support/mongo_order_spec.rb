require 'spec_helper'

module MongoModel
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
end
