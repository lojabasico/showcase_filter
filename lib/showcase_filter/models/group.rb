module ShowcaseFilter
  module Models
    class Group
      include ::Virtus.model

      attribute :label, String
      attribute :entities, Array
    end
  end
end
