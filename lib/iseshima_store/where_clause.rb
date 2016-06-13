module IseshimaStore
  class WhereClause
    attr_reader :conditions

    def initialize(klass)
      # whereチェーンされているモデルのクラス
      @klass = klass
      @conditions = []
    end

    def +(condition)

      # conditions like where(name: 'taro', email: 'taro@gmail.com')
      if condition.is_a?(Hash)
        condition.each do |property, value|
          property = property.to_s
          if property == 'id'
            datastore = IseshimaStore::Connection.current
            key = datastore.key(@klass.to_s, value.to_i)
            @conditions << ['__key__', '=', key]
          else
            @conditions << [property, '=', value]
          end
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
