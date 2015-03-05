module ShowcaseFilter
  module Models    
    class GroupCollection < Array
      def +(other_array)
        self.concat(other_array)
      end

      def find_by_label(label)
        self.select { |group| group.label == label }.first
      end
    end
  end
end
