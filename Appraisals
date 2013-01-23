RAILS_3_1 = "3.1.10"
RAILS_3_2 = "3.2.11"

appraise "rails-3.1" do
  gem "activesupport", RAILS_3_1
  gem "activemodel", RAILS_3_1
end

appraise "rails-3.2" do
  gem "activesupport", RAILS_3_2
  gem "activemodel", RAILS_3_2
end

if RUBY_VERSION >= "1.9"
  appraise "rails-4" do
    gem "activesupport", :git => "https://github.com/rails/rails.git"
    gem "activemodel", :git => "https://github.com/rails/rails.git"
    gem "journey", :git => "https://github.com/rails/journey.git"
  end

  appraise "rails-4-protected-attributes" do
    gem "activesupport", :git => "https://github.com/rails/rails.git"
    gem "activemodel", :git => "https://github.com/rails/rails.git"
    gem "protected_attributes", :git=>"https://github.com/rails/protected_attributes.git"
    gem "journey", :git => "https://github.com/rails/journey.git"
  end

  appraise "rails-4-observers" do
    gem "activesupport", :git => "https://github.com/rails/rails.git"
    gem "activemodel", :git => "https://github.com/rails/rails.git"
    gem "rails-observers", :git => "https://github.com/rails/rails-observers.git"
    gem "journey", :git => "https://github.com/rails/journey.git"
  end

  appraise "mongoid" do
    gem "mongoid"
    gem "activesupport", RAILS_3_2
    gem "activemodel", RAILS_3_2
  end
end

appraise "mongo_mapper" do
  gem "mongo_mapper"
  gem "activesupport", RAILS_3_2
  gem "activemodel", RAILS_3_2
end
