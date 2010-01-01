# require 'spec_helper'
# 
# module MongoModel
#   shared_examples_for "generic has_many_embedded association" do
#     let(:page1) { Page.new }
#     let(:page2) { Page.new }
#     
#     context "when uninitiliazed" do
#       it "should be empty" do
#         subject.pages.should be_empty
#       end
#     end
#     
#     it "should allow a collection of pages to be assigned" do
#       subject.pages = [page1, page2]
#       subject.pages.should == [page1, page2]
#     end
#     
#     it "should allow pages to be added" do
#       subject.pages << page1
#       subject.pages << page2
#       subject.pages.should == [page1, page2]
#     end
#     
#     describe "loading from database" do
#       if specing?(Document)
#         let(:parent) { subject }
#         let(:reloaded) { Article.find(subject.id) }
#       else
#         define_class(:Parent, Document) do
#           property :article, Article
#         end
#         
#         let(:parent) { Parent.new(:article => subject) }
#         let(:reloaded) { Parent.find(parent.id).article }
#       end
#       
#       before(:each) do
#         subject.pages << page1
#         subject.pages << page2
#         parent.save!
#       end
#       
#       it "should load saved pages" do
#         reloaded.pages.should == [page1, page2]
#       end
#     end
#   end
#   
#   specs_for(Document, EmbeddedDocument) do
#     define_class(:Page, EmbeddedDocument)
#     define_class(:Advertisement, EmbeddedDocument)
#     
#     describe "has_many_embedded association" do
#       define_class(:Article, described_class) do
#         has_many_embedded :pages
#       end
#       
#       subject { Article.new }
#       
#       it_should_behave_like "generic has_many_embedded association"
#       
#       describe "adding an instance of a different EmbeddedDocument class to the collection" do
#         it "should raise a AssociationTypeMismatch exception" do
#           lambda { subject.pages << Advertisement.new }.should raise_error(AssociationTypeMismatch, "expected instance of Page but got Advertisement")
#         end
#       end
#     end
#     
#     describe "polymorphic has_many_embedded association" do
#       define_class(:Article, described_class) do
#         has_many_embedded :pages, :polymorphic => true
#       end
#       
#       subject { Article.new }
#       
#       it_should_behave_like "generic has_many_embedded association"
#       
#       describe "adding an instance of a different EmbeddedDocument class to the collection" do
#         let(:ad) { Advertisement.new }
#         
#         it "should add the object to the collection" do
#           subject.pages << ad
#           subject.pages.should == [ad]
#         end
#       end
#     end
#   end
# end
