module ShowcaseFilter
  class Core
    def self.filter(collection)
      collection.inject(ShowcaseFilter::Models::GroupCollection.new([])) {|arr, entity|
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

    def self.match(expression, group_array)
      groups = ShowcaseFilter::Models::GroupCollection.new(group_array).flatten
      match_expression = self.evaluate_expression(expression)

      if match_expression.nil?
        return ShowcaseFilter::Models::GroupCollection.new([])
      end

      group1 = groups.find_by_label(match_expression.group1)
      group2 = groups.find_by_label(match_expression.group2)

      if group1.nil? or group2.nil?
        return ShowcaseFilter::Models::GroupCollection.new([])
      else
        return group1.entities.send(match_expression.operator.to_sym, group2.entities)
      end
    end

    def self.evaluate_expression(expression)
      # Supported operators are : union(+), exclusion(-) and intersection(&)
      regex = /([[:alpha:]|\s]+)\s*(\+|\-|\&)\s*(\w+)/i
      match_result = expression.match(regex)
      return nil if match_result.nil?

      ShowcaseFilter::Models::Expression.new({
          :expression => match_result[0],
          :operator => match_result[2],
          :group1 => match_result[1].strip,
          :group2 => match_result[3].strip
      })
    end
  end
end
