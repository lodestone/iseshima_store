module IseshimaStore
  module QueryMethods
    def where(condition)
      spawn.where!(condition)
    end

    def where!(condition)
      @where_clause += condition
      self
    end

    def all
      to_a
    end

    def to_a
      query = Gcloud::Datastore::Query.new
      query.kind(@klass.to_s)
      @where_clause.conditions.each do |condition|
        query.where(*condition)
      end

      results = IseshimaStore::Connection.current.run(query)
      results.map { |entity| @klass.from_entity(entity) }
    end

    def inspect
      to_a.inspect
    end
  end
end
