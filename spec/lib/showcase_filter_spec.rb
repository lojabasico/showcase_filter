require 'spec_helper'

def variants
  [
    Variant.new("gola c", "branca", "p", 1),
    Variant.new("gola v", "preta", "m", 3),
    Variant.new("gola c", "branca", "m", 0),
    Variant.new("gola c", "azul", "GG", 1)
  ]
end

Variant = Struct.new(:name, :color, :size, :count_on_hand)

describe ShowcaseFilter do
  context "entities collection" do
    it "should know how to break entities in row" do
      entities_collection = ShowcaseFilter::Models::EntityCollection.new([1,2,3,4,5,6,7,8])
      rows = entities_collection.rows(4)
      expect(rows.first.join(',')).to eq '1,2,3,4'
      expect(rows.last.join(',')).to eq '5,6,7,8'
    end
  end

  context "group collection" do
      it {
        s = ShowcaseFilter::Core.filter(variants) do |entity, exclude|
          entity.color
        end

        expect(s.find_by_label("azul").label).to eq "azul"
      }

      it "should work with alias" do
        s = ShowcaseFilter.filter(variants) do |e,ex|
          e.color
        end

        expect(s.find_by_label("azul").label).to eq "azul"
      end

      it "concat group collections should generate a new GroupCollection" do
        g1 = ShowcaseFilter::Models::GroupCollection.new([1])
        g2 = ShowcaseFilter::Models::GroupCollection.new([2])
        expect((g1+g2).count).to eq 2
        expect(g1+g2).to be_a ShowcaseFilter::Models::GroupCollection
      end
  end

  context "evaluate expression" do
    [
      { :type => "union", :expression => "dog+cat", :match1 => "dog", :match2 => "+", :match3 => "cat" },
      { :type => "intersection", :expression => "dog&cat", :match1 => "dog", :match2 => "&", :match3 => "cat" },
      { :type => "exclusion", :expression => "dog-cat", :match1 => "dog", :match2 => "-", :match3 => "cat" },
      { :type => "spaces", :expression => "dog   +   cat", :match1 => "dog", :match2 => "+", :match3 => "cat" },
      { :type => 'acents', :expression => "verde água & p", :match1 => "verde água", :match2 => "&", :match3 => "p"}
    ].each do |info|
      it "should evaluate #{info[:type]} expression" do
        match = ShowcaseFilter::Core.evaluate_expression(info[:expression])
        expect(match).to be_a ShowcaseFilter::Models::Expression
        expect(match.group1).to eq info[:match1]
        expect(match.operator).to eq info[:match2]
        expect(match.group2).to eq info[:match3]
      end
    end

    it "should return false for invalid expressions" do
      match = ShowcaseFilter::Core.evaluate_expression("dog ** cat")
      expect(match).to be nil
    end
  end

  context "group intersection" do
    before(:each) do
      @g1 = ShowcaseFilter::Core.filter(variants) do |entity|
        entity.color
      end
      @g2 = ShowcaseFilter::Core.filter(variants) do |entity|
        entity.size
      end
    end

    it {
      g3 = ShowcaseFilter::Core.match("branca & p", [@g1,@g2])
      expect(g3.count).to eq 1
    }

    it "should return empty array if any group is empty" do
      g3 = ShowcaseFilter::Core.match("branca & pp", [@g1,@g2])
      expect(g3.count).to eq 0
    end

    it "should return empty array if operator is invalid" do
      g3 = ShowcaseFilter::Core.match("branca x pp", [@g1,@g2])
      expect(g3.count).to eq 0
    end

    it "should return empty array if arrays are invalid" do
      g3 = ShowcaseFilter::Core.match("branca x pp", [nil,nil])
      expect(g3.count).to eq 0
    end

    it "should match class" do
      g3 = ShowcaseFilter::Core.match("branca & p", [@g1,@g2])
      expect(g3.count).to eq 1
    end
  end

  context "auto group discover" do
    it "normal case" do
      expect(variants.count).to eq 4

      s = ShowcaseFilter::Core.filter(variants) do |entity|
        entity.color
      end

      expect(s.count).to eq 3
      expect(s.first.label).to eq "branca"
      expect(s.first.entities.count).to eq 2
      expect(s[1].label).to eq "preta"
      expect(s[1].entities.count).to eq 1
      expect(s[2].label).to eq "azul"
      expect(s[2].entities.count).to eq 1
    end

    it "excluding case" do
      s = ShowcaseFilter::Core.filter(variants) do |entity, exclude|
        if entity.count_on_hand > 0
          entity.color
        else
          exclude
        end
      end

      expect(s.count).to eq 3
      expect(s.first.label).to eq "branca"
      expect(s.first.entities.count).to eq 1
      expect(s[1].label).to eq "preta"
      expect(s[1].entities.count).to eq 1
      expect(s[2].label).to eq "azul"
      expect(s[2].entities.count).to eq 1
    end
  end
end
