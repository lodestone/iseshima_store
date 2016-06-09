module IseshimaStore
  class WhereClause
    attr_reader :conditions

    def initialize
      @conditions = []
    end

    def +(condition)

      # conditions like where(name: 'taro', email: 'taro@gmail.com')
      if condition.is_a?(Hash)
        condition.each do |key, value|
          @conditions << [key.to_s, '=', value]
        end
      # condisions like where('age', '>=', 16)
      elsif condition.is_a?(Array) && condition.length == 3
        @conditions << condition
      # Other
      else
        raise ArgumentError.new("wrong format of arguments")
      end

      self
    end
  end
end
