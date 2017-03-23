require 'spec_helper'

module MongoModel
  describe Collection do
    define_class(:TestDocument, EmbeddedDocument)
    let(:doc) { TestDocument.new }

    subject { Collection }

    it { should be_a_subclass_of(Array) }

    it "has type Object" do
      subject.type.should == Object
    end

    it "does not show its type when inspecting" do
      subject.inspect.should == "Collection"
    end

    it "allows any object to be added to the collection" do
      collection = subject.new
      collection << 123
      collection << "Hello"
      collection << doc
      collection.should == [123, "Hello", doc]
    end

    it "converts to mongo representation" do
      collection = subject.new([123, "Hello", doc])
      collection.to_mongo.should == [123, "Hello", { "_type" => 'TestDocument' }]
    end

    it "loads from mongo representation" do
      collection = subject.from_mongo([123, "Hello", { "_type" => 'TestDocument' }])
      collection.should be_a(subject)
      collection.should == [123, "Hello", doc]
    end

    it "caches collection types" do
      Collection[String].should equal(Collection[String])
      Collection[TestDocument].should equal(Collection[TestDocument])
    end

    describe "a Collection of Strings" do
      subject { Collection[String] }

      it { should be_a_subclass_of(Collection) }
      it { should be_a_subclass_of(Array) }

      it "has type String" do
        subject.type.should == String
      end

      it "shows its type when inspecting" do
        subject.inspect.should == "Collection[String]"
      end

      it "converts to mongo representation" do
        collection = subject.new(["a", "bcd", "efg"])
        collection.to_mongo.should == ["a", "bcd", "efg"]
      end

      it "loads from mongo representation" do
        collection = subject.from_mongo(["a", "bcd", "efg"])
        collection.should be_a(subject)
        collection.should == ["a", "bcd", "efg"]
      end

      describe "casting" do
        subject { Collection[String].new }

        it "casts elements when instantiating" do
          Collection[String].new(["abc", 123, 56.2]).should == ["abc", "123", "56.2"]
        end

        it "casts elements on <<" do
          subject << "abc"
          subject << 123
          subject << 56.2
          subject.should == ["abc", "123", "56.2"]
        end

        it "casts elements on []=" do
          subject[0] = "abc"
          subject[1] = 123
          subject[2] = 56.2
          subject.should == ["abc", "123", "56.2"]
        end

        it "casts elements on +" do
          result = subject + ["abc", 123, 56.2]
          result.should be_an_instance_of(Collection[String])
          result.should == ["abc", "123", "56.2"]
        end

        it "casts elements on concat" do
          subject.concat(["abc", 123, 56.2])
          subject.should == ["abc", "123", "56.2"]
        end

        it "casts elements on delete" do
          subject.push("abc", 123, 56.2)
          subject.delete(123)
          subject.delete(56.2)
          subject.should == ["abc"]
        end

        it "casts elements on index" do
          subject.push("abc", 123, 56.2)
          subject.index(123).should == 1
          subject.index(56.2).should == 2
        end

        it "casts elements on insert" do
          subject.insert(0, 56.2)
          subject.insert(0, "abc")
          subject.insert(1, 123)
          subject.should == ["abc", "123", "56.2"]
        end

        it "casts elements on push" do
          subject.push("abc", 123, 56.2)
          subject.should == ["abc", "123", "56.2"]
        end

        it "casts elements on rindex" do
          subject.push("abc", 123, 56.2, 123)
          subject.rindex(123).should == 3
          subject.rindex(56.2).should == 2
        end

        it "casts elements on unshift" do
          subject.unshift("abc")
          subject.unshift(123, 56.2)
          subject.should == ["123", "56.2", "abc"]
        end

        it "casts elements on include?" do
          subject.push("abc", 123, 56.2)
          subject.should include(123)
          subject.should include(56.2)
          subject.should_not include(999)
        end
      end
    end

    describe "a Collection of embedded documents" do
      subject { Collection[TestDocument] }

      it { should be_a_subclass_of(Collection) }
      it { should be_a_subclass_of(Array) }

      it "has type TestDocument" do
        subject.type.should == TestDocument
      end

      it "shows its type when inspecting" do
        subject.inspect.should == "Collection[TestDocument]"
      end

      it "converts to mongo representation" do
        collection = subject.new([doc])
        collection.to_mongo.should == [{ "_type" => 'TestDocument' }]
      end

      it "loads from mongo representation" do
        collection = subject.from_mongo([{ "_type" => 'TestDocument' }])
        collection.should be_a(subject)
        collection.should == [doc]
      end
    end

    describe "a Collection of CustomClasses" do
      subject { Collection[CustomClass] }

      it { should be_a_subclass_of(Collection) }
      it { should be_a_subclass_of(Array) }

      it "has type CustomClass" do
        subject.type.should == CustomClass
      end

      it "shows its type when inspecting" do
        subject.inspect.should == "Collection[CustomClass]"
      end

      it "converts to mongo representation" do
        collection = subject.new([CustomClass.new("abc"), CustomClass.new("123")])
        collection.to_mongo.should == [{ :name => "abc" }, { :name => "123" }]
      end

      it "loads from mongo representation" do
        collection = subject.from_mongo([{ :name => "abc" }, { :name => "123" }])
        collection.should be_a(subject)
        collection.should == [CustomClass.new("abc"), CustomClass.new("123")]
      end

      it "loads from mongo representation of single item" do
        collection = subject.from_mongo({ :name => "abc" })
        collection.should be_a(subject)
        collection.should == [CustomClass.new("abc")]
      end
    end
  end

  specs_for(Document, EmbeddedDocument) do
    describe "defining a Collection property with default value" do
      define_class(:TestDocument, described_class) do
        property :test_collection, Collection[CustomClass], :default => ['abc', 'def']
      end

      subject { TestDocument.new }

      it "casts items to collection type" do
        subject.test_collection.should == [CustomClass.new('abc'), CustomClass.new('def')]
      end

      it "allows items to be added to collection" do
        subject.test_collection << '123'
        subject.test_collection.should == [CustomClass.new('abc'), CustomClass.new('def'), CustomClass.new('123')]
      end

      it "does not share collections between instances" do
        subject.test_collection << '123'
        TestDocument.new.test_collection.should_not == subject.test_collection
      end
    end

    describe "with a Collection containing EmbeddedDocuments" do
      define_class(:Embedded, EmbeddedDocument) do
        property :number, Integer
      end

      define_class(:TestDocument, described_class) do
        property :embedded, Embedded
        property :embedded_collection, Collection[Embedded]
      end

      let(:embedded1) { Embedded.new(:number => 1) }
      let(:embedded2) { Embedded.new(:number => 2) }
      let(:embedded3) { Embedded.new(:number => 3) }

      let(:empty) { TestDocument.new }
      subject { TestDocument.new(:embedded => embedded1, :embedded_collection => [embedded2, embedded3]) }

      it "defaults to an empty collection" do
        empty.embedded_collection.should be_an_instance_of(Collection[Embedded])
        empty.embedded_collection.should be_empty
      end

      it "includes the embedded properties in the embedded documents list" do
        subject.embedded_documents.should include(embedded1)
      end

      it "includes the elements in the collection in the embedded documents list" do
        subject.embedded_documents.should include(embedded2, embedded3)
      end

      it "casts items to embedded document class when assigning array of hashes" do
        subject.embedded_collection = [ { :number => 5 }, { :number => 99 } ]
        subject.embedded_collection.should == [ Embedded.new(:number => 5), Embedded.new(:number => 99) ]
      end

      it "casts items to embedded document class when assigning collection hash" do
        subject.embedded_collection = { :_collection => true, :items => [ { :number => 49 }, { :number => 64 } ] }
        subject.embedded_collection.should == [ Embedded.new(:number => 49), Embedded.new(:number => 64) ]
      end

      it "casts item to embedded document class when assigning attributes hash" do
        subject.embedded_collection = { :number => 8 }
        subject.embedded_collection.should == [ Embedded.new(:number => 8) ]
      end
    end
  end
end
