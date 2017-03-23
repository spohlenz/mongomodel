require 'spec_helper'

module MongoModel
  describe Map do
    subject { Map }

    define_class(:TestDocument, EmbeddedDocument) do
      property :name, String

      def self.cast(name)
        new(:name => name)
      end
    end

    let(:doc) { TestDocument.new(:name => "Foobar") }

    it { should be_a_subclass_of(Hash) }

    it "has from type String" do
      subject.from.should == String
    end

    it "has to type Object" do
      subject.to.should == Object
    end

    it "does not show its type when inspecting" do
      subject.inspect.should == "Map"
    end

    it "allows any string->object mappings to be added" do
      map = subject.new
      map["hello"] = 123
      map["foo"] = "Bonjour"
      map["mydoc"] = doc
      map.should == { "hello" => 123, "foo" => "Bonjour", "mydoc" => doc }
    end

    it "converts to mongo representation" do
      map = subject.new({ "hello" => 123, "mydoc" => doc })
      map.to_mongo.should == { "hello" => 123, "mydoc" => { "_type" => 'TestDocument', "name" => "Foobar" } }
    end

    it "loads from mongo representation" do
      map = subject.from_mongo({ "hello" => 123, "mydoc" => { "_type" => 'TestDocument', "name" => "Foobar" } })
      map.should be_a(subject)
      map.should == { "hello" => 123, "mydoc" => doc }
    end

    it "caches map types" do
      Map[Symbol => String].should equal(Map[Symbol => String])
      Map[String => TestDocument].should equal(Map[String => TestDocument])
    end

    describe "map from String to String" do
      let(:klass) { Map[String => String] }
      subject { klass.new("123" => "456", "12.5" => "foobar") }

      it "shows its types when inspecting" do
        klass.inspect.should == "Map[String => String]"
      end

      it "casts key/values when instantiating" do
        map = klass.new(123 => 456, 12.5 => :foobar)
        map.should == { "123" => "456", "12.5" => "foobar" }
      end

      it "casts keys on []" do
        subject[123].should == "456"
      end

      it "casts key/values on []=" do
        subject[12.5] = 456
        subject["12.5"].should == "456"
      end

      it "casts key/values on #store" do
        subject.store(12.5, 456)
        subject["12.5"].should == "456"
      end

      it "casts keys on #delete" do
        subject.delete(123)
        subject["123"].should be_nil
      end

      it "casts keys on #fetch" do
        subject.fetch(123).should == "456"
        subject.fetch(999, "default").should == "default"
      end

      it "casts keys on #has_key?, #include?, #key?, #member?" do
        subject.has_key?(123).should be true
        subject.include?(12.5).should be true
        subject.key?(123).should be true
        subject.member?(12.5).should be true
      end

      it "casts values on #has_value?, #value?" do
        subject.has_value?(456).should be true
        subject.value?(456).should be true
      end

      if Hash.method_defined?(:key)
        it "casts values on #key" do
          subject.key(456).should == "123"
        end
      else
        it "casts values on #index" do
          subject.index(456).should == "123"
        end
      end

      it "casts key/values on #replace" do
        subject.replace(321 => 654, 5.12 => :barbaz)
        subject.should == { "321" => "654", "5.12" => "barbaz" }
      end

      it "casts key/values on #merge" do
        map = subject.merge(321 => 654, 5.12 => :barbaz)
        map.should == { "123" => "456", "12.5" => "foobar", "321" => "654", "5.12" => "barbaz" }
      end

      it "casts key/values on #merge!" do
        subject.merge!(321 => 654, 5.12 => :barbaz)
        subject.should == { "123" => "456", "12.5" => "foobar", "321" => "654", "5.12" => "barbaz" }
      end

      it "casts keys on #values_at" do
        subject.values_at(12.5, 123).should == ["foobar", "456"]
      end
    end

    describe "map from Symbol to TestDocument" do
      let(:doc1) { TestDocument.new(:name => "First") }
      let(:doc2) { TestDocument.new(:name => "Another") }

      let(:klass) { Map[Symbol => TestDocument] }
      subject { klass.new(:abc => doc1, :another => doc2) }

      it "shows its types when inspecting" do
        klass.inspect.should == "Map[Symbol => TestDocument]"
      end

      it "casts key/values when instantiating" do
        map = klass.new("foo" => "First", "123" => "Another")
        map.should == { :foo => doc1, :"123" => doc2 }
      end

      it "casts keys on []" do
        subject["abc"].should == doc1
      end

      it "casts key/values on []=" do
        subject["def"] = "Another"
        subject[:def].should == doc2
      end

      it "casts key/values on #store" do
        subject.store("def", "Another")
        subject[:def].should == doc2
      end

      it "casts keys on #delete" do
        subject.delete("abc")
        subject[:abc].should be_nil
      end

      it "casts keys on #fetch" do
        subject.fetch("abc").should == doc1
        subject.fetch("999", "default").should == "default"
      end

      it "casts keys on #has_key?, #include?, #key?, #member?" do
        subject.has_key?("abc").should be true
        subject.include?("another").should be true
        subject.key?("abc").should be true
        subject.member?("another").should be true
      end

      it "casts values on #has_value?, #value?" do
        subject.has_value?("First").should be true
        subject.value?("Another").should be true
      end

      if Hash.method_defined?(:key)
        it "casts values on #key" do
          subject.key("First").should == :abc
        end
      else
        it "casts values on #index" do
          subject.index("First").should == :abc
        end
      end

      it "casts key/values on #replace" do
        subject.replace("321" => "Bonus", "hello" => "Another")
        subject.should == { :"321" => TestDocument.new(:name => "Bonus"), :hello => doc2 }
      end

      it "casts key/values on #merge" do
        map = subject.merge("321" => "Bonus", "hello" => "Another")
        map.should == { :abc => doc1, :another => doc2, :"321" => TestDocument.new(:name => "Bonus"), :hello => doc2 }
      end

      it "casts key/values on #merge!" do
        subject.merge!("321" => "Bonus", "hello" => "Another")
        subject.should == { :abc => doc1, :another => doc2, :"321" => TestDocument.new(:name => "Bonus"), :hello => doc2 }
      end

      it "casts keys on #values_at" do
        subject.values_at(:another, :abc).should == [doc2, doc1]
      end
    end

    describe "map from Date to String" do
      let(:klass) { Map[Date => String] }
      subject { klass.new(Date.civil(2009, 11, 15) => "Hello world") }

      it "casts key to String on #to_mongo" do
        subject.to_mongo.should == { "2009/11/15" => "Hello world" }
      end
    end
  end

  specs_for(Document, EmbeddedDocument) do
    define_class(:ChildDocument, EmbeddedDocument) do
      property :name, String

      def self.cast(name)
        new(:name => name)
      end
    end

    describe "defining a Map property containing EmbeddedDocument values" do
      define_class(:TestDocument, described_class) do
        property :test_map, Map[String => ChildDocument]
      end

      let(:child1) { ChildDocument.new(:name => "Child 1") }
      let(:child2) { ChildDocument.new(:name => "Child 2") }

      subject { TestDocument.new(:test_map => { "1" => child1, "2" => child2 }) }

      it "includes the map values in the embedded documents list" do
        subject.embedded_documents.should include(child1, child2)
      end
    end

    describe "defining a Map property with no default value" do
      define_class(:TestDocument, described_class) do
        property :test_map, Map[Symbol => ChildDocument]
      end

      subject { TestDocument.new }

      it "defaults to an empty map" do
        subject.test_map.should be_an_instance_of(Map[Symbol => ChildDocument])
        subject.test_map.should be_empty
      end
    end

    describe "defining a Map property with a default value" do
      define_class(:TestDocument, described_class) do
        property :test_map, Map[Symbol => ChildDocument], :default => { :abc => 'abc', 'def' => 'def' }
      end

      subject { TestDocument.new }

      it "casts key/values to map type" do
        subject.test_map[:abc].should == ChildDocument.new(:name => 'abc')
        subject.test_map[:def].should == ChildDocument.new(:name => 'def')
      end
    end
  end
end
