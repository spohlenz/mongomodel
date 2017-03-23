require 'spec_helper'

module MongoModel
  describe Paginator do
    let(:entries) { [double] * 10 }
    let(:scope) { double(:count => 35, :limit => entries).as_null_object }
    let(:page) { 2 }
    let(:per_page) { 10 }

    subject { Paginator.new(scope, page, per_page) }

    it { should be_a_kind_of(Array) }

    its(:total_entries) { should == 35 }
    its(:total_pages) { should == 4 }

    its(:current_page) { should == 2 }
    its(:previous_page) { should == 1 }
    its(:next_page) { should == 3 }
    its(:offset) { should == 10 }

    its(:size) { should == 10 }

    it { should_not be_out_of_bounds }

    context "first page" do
      let(:page) { 1 }

      its(:previous_page) { should be_nil }
      its(:next_page) { should == 2 }
      its(:offset) { should == 0 }
    end

    context "last page" do
      let(:entries) { [double] * 5 }
      before { scope.stub(:count => nil) }

      let(:page) { 4 }

      its(:previous_page) { should == 3 }
      its(:next_page) { should be_nil }
    end

    context "no entries" do
      before { scope.stub(:count => 0) }

      its(:total_pages) { should == 1 }
    end

    context "out of bounds" do
      let(:page) { 5 }

      it { should be_out_of_bounds }
    end
  end
end
