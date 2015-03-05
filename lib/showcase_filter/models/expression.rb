module ShowcaseFilter
  module Models
    class Expression
      include ::Virtus.model

      attribute :expression, String
      attribute :operator, String
      attribute :group1, String
      attribute :group2, String
    end
  end
end
