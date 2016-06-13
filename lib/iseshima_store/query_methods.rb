module IseshimaStore
  module QueryMethods
    def where(condition)
      spawn.where!(condition)
    end

    def where!(condition)
      @where_clause += condition
      self
    end

    def parent(model)
      if model.respond_to?(:key)
        @parent_key = model.key
      end
      self
    end

    def all
      to_a
    end

    def exists?
      to_a.length > 0
    end

    def to_a
      query = Gcloud::Datastore::Query.new
      query.kind(@klass.to_s)
      @where_clause.conditions.each do |condition|
        query.where(*condition)
      end
      if @parent_key
        query.ancestor(@parent_key)
      end
      results = IseshimaStore::Connection.current.run(query)
      results.map { |entity| @klass.from_entity(entity) }
    end

    def inspect
      to_a.inspect
    end

    def find(_id)
      entity = where(id: _id).first
      unless entity
        raise EntityNotFound.new("cannot find entity with id #{_id}")
      end
      entity
    end

    def find_by(hash)
      where(hash).first
    end
  end
end
