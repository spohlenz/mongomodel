require 'spec_helper'

module MongoModel
  describe "MapReduce" do
    describe "counting tags" do
      # This example is extracted from the Counting Tags pattern in the
      # MongoDB Cookbook: http://cookbook.mongodb.org/patterns/count_tags/

      define_class(:Article, Document) do
        property :tags, Collection[String]
      end

      define_class(:Tag, Struct.new(:name, :count)) do
        include MongoModel::MapReduce

        self.parent_collection = Article.collection

        def initialize(name, count)
          super(name, count.to_i)
        end

        def self.map_function
          <<-MAP
          function() {
            if (!this.tags) { return; }

            for (i in this.tags) {
              emit(this.tags[i], 1);
            }
          }
          MAP
        end

        def self.reduce_function
          <<-REDUCE
          function(key, values) {
            var count = 0;

            for (i in values) {
              count += values[i];
            }

            return count;
          }
          REDUCE
        end
      end

      specify "tag comparison" do
        Tag.new("Tag 1", 1).should == Tag.new("Tag 1", 1)
        Tag.new("Tag 2", 1).should_not == Tag.new("Tag 1", 1)
        Tag.new("Tag 1", 1).should_not == Tag.new("Tag 1", 2)
      end

      before do
        Article.create!(:tags => ["Tag 1", "Tag 2"])
        Article.create!(:tags => ["Tag 2"])
        Article.create!(:tags => ["Tag 3"])
      end

      it "has a default collection name based on the parent collection" do
        Tag.collection_name.should == "articles._tags"
      end

      it "stores the result in a named collection" do
        Tag.collection.name.should == Tag.collection_name
      end

      it "allows use of scope methods" do
        Tag.all.should == [Tag.new("Tag 1", 1), Tag.new("Tag 2", 2), Tag.new("Tag 3", 1)]
        Tag.order(:value.desc).first.should == Tag.new("Tag 2", 2)
        Tag.where(:value.gt => 1).should == [Tag.new("Tag 2", 2)]
      end

      it "loads previously computed results" do
        expected = Tag.all
        Article.create!(:tags => ["Tag 1"])
        Tag.cached.should == expected
      end
    end

    describe "pivot data" do
      # This example is similar to the Pivot Data pattern in the
      # MongoDB Cookbook: http://cookbook.mongodb.org/patterns/pivot/

      define_class(:Actor, Document) do
        property :name, String
        property :movies, Collection[String]
      end

      define_class(:Movie, Struct.new(:name, :actors)) do
        include MongoModel::MapReduce

        self.parent_collection = Actor.collection

        def self.from_mongo(attrs)
          new(attrs['_id'], attrs['value']['actors'].sort)
        end

        def self.map_function
          <<-MAP
          function() {
            for (i in this.movies) {
              emit(this.movies[i], { actors: [this.name] });
            }
          }
          MAP
        end

        def self.reduce_function
          <<-REDUCE
          function(key, values) {
            var result = { actors: [] };

            for (i in values) {
              result.actors = result.actors.concat(values[i].actors);
            }

            return result;
          }
          REDUCE
        end
      end

      before do
        Actor.create!(:name => "Richard Gere", :movies => ['Pretty Woman', 'Runaway Bride', 'Chicago'])
        Actor.create!(:name => "Julia Roberts", :movies => ['Pretty Woman', 'Runaway Bride', 'Erin Brockovich'])
      end

      it "pivots data" do
        Movie.all.should include(
          Movie.new("Pretty Woman", ["Julia Roberts", "Richard Gere"]),
          Movie.new("Runaway Bride", ["Julia Roberts", "Richard Gere"]),
          Movie.new("Chicago", ["Richard Gere"]),
          Movie.new("Erin Brockovich", ["Julia Roberts"])
        )
      end
    end
  end
end
