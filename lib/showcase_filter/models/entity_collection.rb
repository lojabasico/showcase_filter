module ShowcaseFilter
  module Models
    class EntityCollection < Array
      def rows(value)
        self.each_slice(value).to_a
      end
    end
  end
end
