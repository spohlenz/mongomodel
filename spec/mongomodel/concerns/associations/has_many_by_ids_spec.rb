require 'spec_helper'

module MongoModel
  specs_for(EmbeddedDocument) do
    describe "has_many association" do
      define_class(:Book, EmbeddedDocument) do
        has_many :chapters
      end

      it "defaults to :by => :ids" do
        Book.associations[:chapters].should be_a(Associations::HasManyByIds)
      end
    end
  end

  specs_for(Document, EmbeddedDocument) do
    shared_examples_for "accessing and manipulating a has_many :by => :ids association" do
      it "accesses chapters" do
        subject.chapters.should == [chapter1, chapter2]
      end

      it "accesses chapter ids through association" do
        subject.chapters.ids.should == [chapter1.id, chapter2.id]
      end

      it "has chapter ids" do
        subject.chapter_ids.should == [chapter1.id, chapter2.id]
      end

      it "adds chapters with <<" do
        subject.chapters << chapter3
        subject.chapters.should == [chapter1, chapter2, chapter3]
        subject.chapter_ids.should == [chapter1.id, chapter2.id, chapter3.id]
      end

      it "adds/change chapters with []=" do
        subject.chapters[2] = chapter3
        subject.chapters.should == [chapter1, chapter2, chapter3]
        subject.chapter_ids.should == [chapter1.id, chapter2.id, chapter3.id]
      end

      it "adds chapters with concat" do
        subject.chapters.concat([chapter3])
        subject.chapters.should == [chapter1, chapter2, chapter3]
        subject.chapter_ids.should == [chapter1.id, chapter2.id, chapter3.id]
      end

      it "inserts chapters" do
        subject.chapters.insert(1, chapter3)
        subject.chapters.should == [chapter1, chapter3, chapter2]
        subject.chapter_ids.should == [chapter1.id, chapter3.id, chapter2.id]
      end

      it "replaces chapters" do
        subject.chapters.replace([chapter2, chapter3])
        subject.chapters.should == [chapter2, chapter3]
        subject.chapter_ids.should == [chapter2.id, chapter3.id]
      end

      it "adds chapters with push" do
        subject.chapters.push(chapter3)
        subject.chapters.should == [chapter1, chapter2, chapter3]
        subject.chapter_ids.should == [chapter1.id, chapter2.id, chapter3.id]
      end

      it "adds chapters with unshift" do
        subject.chapters.unshift(chapter3)
        subject.chapters.should == [chapter3, chapter1, chapter2]
        subject.chapter_ids.should == [chapter3.id, chapter1.id, chapter2.id]
      end

      it "clears chapters" do
        subject.chapters.clear
        subject.chapters.should be_empty
        subject.chapter_ids.should be_empty
      end

      it "removes chapters with delete" do
        subject.chapters.delete(chapter1)
        subject.chapters.should == [chapter2]
        subject.chapter_ids.should == [chapter2.id]
      end

      it "removes chapters with delete_at" do
        subject.chapters.delete_at(0)
        subject.chapters.should == [chapter2]
        subject.chapter_ids.should == [chapter2.id]
      end

      it "removes chapters with delete_if" do
        subject.chapters.delete_if { |c| c.id == chapter1.id }
        subject.chapters.should == [chapter2]
        subject.chapter_ids.should == [chapter2.id]
      end

      it "builds a chapter" do
        chapter4 = subject.chapters.build(:id => '4')
        subject.chapters.should == [chapter1, chapter2, chapter4]
        subject.chapter_ids.should == [chapter1.id, chapter2.id, chapter4.id]

        chapter4.should be_a_new_record
        chapter4.id.should == '4'
      end

      it "creates a chapter" do
        chapter4 = subject.chapters.create(:id => '4')
        subject.chapters.should == [chapter1, chapter2, chapter4]
        subject.chapter_ids.should == [chapter1.id, chapter2.id, chapter4.id]

        chapter4.should_not be_a_new_record
        chapter4.id.should == '4'
      end

      it "finds chapters" do
        # Create bogus chapters
        Chapter.create!(:id => '999')
        Chapter.create!(:id => '998')

        result = subject.chapters.order(:id.desc)
        result.should == [chapter2, chapter1]
      end

      describe "adding a non-chapter" do
        def self.should_raise(message, &block)
          it "raises an AsssociationTypeMismatch error when #{message}" do
            lambda { instance_eval(&block) }.should raise_error(AssociationTypeMismatch, "Chapter expected, got NonChapter")
          end
        end

        should_raise("assigning an array containing non-chapters") { subject.chapters = [nonchapter] }
        should_raise("adding a non-chapter using <<") { subject.chapters << nonchapter }
        should_raise("adding non-chapters with concat") { subject.chapters.concat([nonchapter]) }
        should_raise("inserting chapters") { subject.chapters.insert(1, nonchapter) }
        should_raise("replacing chapters") { subject.chapters.replace([nonchapter]) }
        should_raise("addding chapters with push") { subject.chapters.push(nonchapter) }
        should_raise("addding chapters with unshift") { subject.chapters.unshift(nonchapter) }
      end
    end

    describe "has_many :by => :ids association" do
      define_class(:Chapter, Document)
      define_class(:IllustratedChapter, :Chapter)
      define_class(:Book, described_class) do
        has_many :chapters, :by => :ids
      end
      define_class(:NonChapter, Document)

      let(:chapter1) { Chapter.create!(:id => '1') }
      let(:chapter2) { IllustratedChapter.create!(:id => '2') }
      let(:chapter3) { Chapter.create!(:id => '3') }
      let(:nonchapter) { NonChapter.create! }

      context "when uninitialized" do
        subject { Book.new }

        it "is empty" do
          subject.chapters.should be_empty
        end

        it "has an empty ids array" do
          subject.chapter_ids.should be_empty
        end
      end

      context "with chapters set" do
        subject { Book.new(:chapters => [chapter1, chapter2]) }
        it_should_behave_like "accessing and manipulating a has_many :by => :ids association"
      end

      context "with chapter ids set" do
        subject { Book.new(:chapter_ids => [chapter1.id, chapter2.id]) }
        it_should_behave_like "accessing and manipulating a has_many :by => :ids association"
      end

      context "when loaded from database" do
        if specing?(Document)
          let(:book) { Book.create!(:chapter_ids => [chapter1.id, chapter2.id]) }
          subject { Book.find(book.id) }
        else
          define_class(:Bookshelf, Document) do
            property :book, Book
          end
          let(:book) { Book.new(:chapter_ids => [chapter1.id, chapter2.id]) }
          let(:shelf) { Bookshelf.create!(:book => book) }
          subject { Bookshelf.find(shelf.id).book }
        end

        it_should_behave_like "accessing and manipulating a has_many :by => :ids association"

        context "when child objects are destroyed" do
          it "does not load the deleted child objects" do
            chapter1.destroy
            subject.chapters.should === [chapter2]
          end
        end
      end

      describe "with :dependent => :destroy option" do
        define_class(:Book, described_class) do
          has_many :chapters, :by => :ids, :dependent => :destroy
        end

        if specing?(Document)
          subject { Book.create!(:chapters => [chapter1, chapter2, chapter3]) }
        else
          define_class(:Bookshelf, Document) do
            property :book, Book
          end
          let(:book) { Book.new(:chapters => [chapter1, chapter2, chapter3]) }
          subject { Bookshelf.create!(:book => book) }
        end

        context "when the parent object is destroyed" do
          it "calls destroy on the child objects" do
            chapter1.should_receive(:destroy)
            chapter2.should_receive(:destroy)
            chapter3.should_receive(:destroy)

            subject.destroy
          end

          it "removes the child objects from their collection" do
            subject.destroy

            Chapter.exists?(chapter1.id).should be false
            Chapter.exists?(chapter2.id).should be false
            Chapter.exists?(chapter3.id).should be false
          end
        end
      end

      describe "with :dependent => :delete option" do
        define_class(:Book, described_class) do
          has_many :chapters, :by => :ids, :dependent => :delete
        end

        if specing?(Document)
          subject { Book.create!(:chapters => [chapter1, chapter2, chapter3]) }
        else
          define_class(:Bookshelf, Document) do
            property :book, Book
          end
          let(:book) { Book.new(:chapters => [chapter1, chapter2, chapter3]) }
          subject { Bookshelf.create!(:book => book) }
        end

        context "when the parent object is destroyed" do
          it "does not call destroy on the child objects" do
            chapter1.should_not_receive(:destroy)
            chapter2.should_not_receive(:destroy)
            chapter3.should_not_receive(:destroy)

            subject.destroy
          end

          it "removes the child objects from their collection" do
            subject.destroy

            Chapter.exists?(chapter1.id).should be false
            Chapter.exists?(chapter2.id).should be false
            Chapter.exists?(chapter3.id).should be false
          end
        end
      end
    end
  end
end
