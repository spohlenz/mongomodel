require 'spec_helper'

module MongoModel
  specs_for(Document) do
    describe "has_many association" do
      define_class(:MyBook, Document) do
        has_many :chapters
      end
      
      it "defaults to :by => :foreign_key" do
        MyBook.associations[:chapters].should be_a(Associations::HasManyByForeignKey)
      end
      
      it "sets default inverse_of value" do
        MyBook.associations[:chapters].inverse_of.should == :my_book
      end
    end
    
    describe "has_many :by => :foreign_key association" do
      define_class(:Chapter, Document) do
        belongs_to :book
      end
      define_class(:IllustratedChapter, :Chapter)
      define_class(:Book, Document) do
        has_many :chapters, :by => :foreign_key, :limit => 5, :order => :id.asc
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
      end
      
      shared_examples_for "accessing and manipulating a has_many :by => :foreign_key association" do
        it "accesses chapters" do
          subject.chapters.should include(chapter1, chapter2)
        end
        
        it "accesses chapter ids through association" do
          subject.chapters.ids.should include(chapter1.id, chapter2.id)
        end
        
        it "adds chapters with <<" do
          subject.chapters << chapter3
          subject.chapters.should include(chapter1, chapter2, chapter3)
          chapter3.book.should == subject
        end
        
        it "adds/change chapters with []=" do
          subject.chapters[2] = chapter3
          subject.chapters.should include(chapter1, chapter2, chapter3)
          chapter3.book.should == subject
        end
        
        it "replaces chapters with []=" do
          subject.chapters[1] = chapter3
          subject.chapters.should include(chapter1, chapter3)
          subject.chapters.should_not include(chapter2)
          #chapter2.book.should be_nil
        end
        
        it "adds chapters with concat" do
          subject.chapters.concat([chapter3])
          subject.chapters.should include(chapter1, chapter2, chapter3)
          chapter3.book.should == subject
        end
        
        it "inserts chapters" do
          subject.chapters.insert(1, chapter3)
          subject.chapters.should include(chapter1, chapter2, chapter3)
          chapter3.book.should == subject
        end
        
        # it "should replace chapters" do
        #   subject.chapters.replace([chapter2, chapter3])
        #   subject.chapters.should == [chapter2, chapter3]
        #   subject.chapter_ids.should == [chapter2.id, chapter3.id]
        # end
        
        it "adds chapters with push" do
          subject.chapters.push(chapter3)
          subject.chapters.should include(chapter1, chapter2, chapter3)
          chapter3.book.should == subject
        end
        
        it "adds chapters with unshift" do
          subject.chapters.unshift(chapter3)
          subject.chapters.should include(chapter3, chapter1, chapter2)
          chapter3.book.should == subject
        end
        
        # it "should clear chapters" do
        #   subject.chapters.clear
        #   subject.chapters.should be_empty
        #   [chapter1, chapter2].each { |c| c.book.should be_nil }
        # end
        
        it "removes chapters with delete" do
          subject.chapters.delete(chapter1)
          subject.chapters.should == [chapter2]
          chapter1.book.should be_nil
        end
        
        it "removes chapters with delete_at" do
          subject.chapters.delete_at(0)
          subject.chapters.should == [chapter2]
          #chapter1.book.should be_nil
        end
        
        # it "should remove chapters with delete_if" do
        #   subject.chapters.delete_if { |c| c.id == chapter1.id }
        #   subject.chapters.should == [chapter2]
        #   subject.chapter_ids.should == [chapter2.id]
        # end
        
        it "builds a chapter" do
          chapter4 = subject.chapters.build(:id => '4')
          subject.chapters.should include(chapter1, chapter2, chapter4)
          
          chapter4.should be_a_new_record
          chapter4.id.should == '4'
          chapter4.book.should == subject
          chapter4.book_id.should == subject.id
        end
        
        it "creates a chapter" do
          chapter4 = subject.chapters.create(:id => '4')
          subject.chapters.should == [chapter1, chapter2, chapter4]
          
          chapter4.should_not be_a_new_record
          chapter4.id.should == '4'
          chapter4.book.should == subject
          chapter4.book_id.should == subject.id
        end
        
        it "finds chapters" do
          # Create bogus chapters
          Chapter.create!(:id => '999')
          Chapter.create!(:id => '998')
          
          result = subject.chapters.order(:id.desc)
          result.should == [chapter2, chapter1]
        end
        
        it "finds chapters with association options" do
          # Create bogus chapters
          10.times { subject.chapters.create! }
          
          subject.chapters.all.size.should == 5 # limit clause
        end
        
        it "supports scope select method" do
          subject.chapters.select(:id, :_type, :book_id).should == [chapter1, chapter2]
        end
        
        it "supports array select method" do
          subject.chapters.select { |c| c.is_a?(IllustratedChapter) }.should == [chapter2]
        end
      end
      
      context "new instance with chapters set" do
        subject { Book.new(:chapters => [chapter1, chapter2]) }
        it_should_behave_like "accessing and manipulating a has_many :by => :foreign_key association"
      end
      
      context "when loaded from database" do
        let(:book) { Book.create!(:chapters => [chapter1, chapter2]) }
        subject { Book.find(book.id) }
        it_should_behave_like "accessing and manipulating a has_many :by => :foreign_key association"
      end
      
      describe "with :dependent => :destroy option" do
        define_class(:Book, Document) do
          has_many :chapters, :by => :foreign_key, :dependent => :destroy
        end
        
        subject { Book.create!(:chapters => [chapter1, chapter2, chapter3]) }
        
        context "when the parent object is destroyed" do
          it "calls destroy on the child objects" do
            chapter1.should_receive(:destroy)
            chapter2.should_receive(:destroy)
            chapter3.should_receive(:destroy)
            
            subject.destroy
          end
          
          it "removes the child objects from their collection" do
            subject.destroy
            
            Chapter.exists?(chapter1.id).should be_false
            Chapter.exists?(chapter2.id).should be_false
            Chapter.exists?(chapter3.id).should be_false
          end
        end
      end
      
      describe "with :dependent => :delete option" do
        define_class(:Book, Document) do
          has_many :chapters, :by => :foreign_key, :dependent => :delete
        end
        
        subject { Book.create!(:chapters => [chapter1, chapter2, chapter3]) }
        
        context "when the parent object is destroyed" do
          it "does not call destroy on the child objects" do
            chapter1.should_not_receive(:destroy)
            chapter2.should_not_receive(:destroy)
            chapter3.should_not_receive(:destroy)
            
            subject.destroy
          end
          
          it "removes the child objects from their collection" do
            subject.destroy
            
            Chapter.exists?(chapter1.id).should be_false
            Chapter.exists?(chapter2.id).should be_false
            Chapter.exists?(chapter3.id).should be_false
          end
        end
      end
    end
  end
  
  specs_for(EmbeddedDocument) do
    describe "defining a has_many :by => :foreign_key association" do
      define_class(:Book, EmbeddedDocument)
      
      it "raises an exception" do
        lambda { Book.has_many :chapters, :by => :foreign_key }.should raise_error
      end
    end
  end
end
