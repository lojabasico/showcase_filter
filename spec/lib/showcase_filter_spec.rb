require 'spec_helper'

Variant = Struct.new(:name, :color, :size, :count_on_hand)

module ShowcaseFilter
  class Core
    def self.auto_discover(collection)
      collection.inject([]) {|arr, entity|
        attribute = yield(entity, Constants::ExcludeEntity.new(true))
        a = arr.select {|group| group.label == attribute}
        if attribute.class != Constants::ExcludeEntity
          if a.empty?
            group = Models::Group.new(label: attribute)
          else
            group = a.first
          end
          group.entities << entity
          arr << group
        end
        arr
      }.uniq
    end
  end
  module Constants
    ExcludeEntity = Struct.new(:exclude)
  end
  module Models
    class Group
      include ::Virtus.model

      attribute :label, String
      attribute :entities, Array
    end
  end
end

describe ShowcaseFilter do
  let(:variants){[
    Variant.new("gola c", "branca", "p", 1),
    Variant.new("gola v", "preta", "m", 3),
    Variant.new("gola c", "branca", "m", 0),
    Variant.new("gola c", "azul", "GG", 1)
  ]}
  context "auto group discover" do
    it{
      expect(variants.count).to eq 4

      s = ShowcaseFilter::Core.auto_discover(variants) do |entity|
        entity.color
      end
      expect(s.count).to eq 3


      expect(s.first.label).to eq "branca"
      expect(s.first.entities.count).to eq 2

      expect(s[1].label).to eq "preta"
      expect(s[1].entities.count).to eq 1

      expect(s[2].label).to eq "azul"
      expect(s[2].entities.count).to eq 1
    }

    it{
      s = ShowcaseFilter::Core.auto_discover(variants) do |entity, exclude|
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

    }
  end
end
