require 'gcloud/datastore'

module IseshimaStore
  module Base
    def self.included(klass)
      klass.extend ClassMethods
    end

    module ClassMethods
      attr_reader :properties

      def attr_properties(*args)
        @properties = args
      end

      def from_entity(entity)
        instance = self.new
        instance.id = entity.key.id
        entity.properties.to_hash.each do |name, value|
          instance.send "#{name}=", value
        end
        instance
      end

      def query(options = {})
        query = Gcloud::Datastore::Query.new
        query.kind(self.to_s)
        query.limit options[:limit]   if options[:limit]
        query.cursor options[:cursor] if options[:cursor]

        results = IseshimaStore::Connection.current.run(query)
        records = results.map { |entity| from_entity(entity) }

        if options[:limit] && results.size == options[:limit]
          next_cursor = results.cursor
        end

        { records: records, cursor: next_cursor }
      end
    end

    def save!
      entity = to_entity
      IseshimaStore::Connection.current.save(entity)
      self.id = entity.key.id
      self
    end

    def to_entity
      entity = Gcloud::Datastore::Entity.new
      entity.key = Gcloud::Datastore::Key.new(self.class.to_s, id)
      self.class.properties.each do |property|
        entity[property] = send(property)
      end
      entity
    end
  end
end
