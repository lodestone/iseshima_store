require 'forwardable'
require 'gcloud/datastore'
require 'iseshima_store/relation'

#http://googlecloudplatform.github.io/gcloud-ruby/docs/master/Gcloud/Datastore.html

module IseshimaStore
  module Base

    def self.included(klass)
      klass.extend SingleForwardable
      klass.extend ClassMethods
      klass.def_delegators :scoping, :where, :all, :to_a

      klass.instance_eval do
        attr_accessor :created_at, :description
      end
    end

    module ClassMethods
      attr_reader :properties

      def scoping
        IseshimaStore::Relation.new(self)
      end

      def find(_id)
        datastore = IseshimaStore::Connection.current
        key = datastore.key(self.to_s, _id.to_i)
        entity = datastore.find(key)
        from_entity(entity)
      end

      def attr_properties(*args)
        @properties = args
      end

      def find_by(hash)
        key, value = hash.keys.first.to_s, hash.values.first.to_s
        query = Gcloud::Datastore::Query.new
        query.kind(self.to_s)
        query.where(key, '=', value)
        results = IseshimaStore::Connection.current.run(query)
        results.map { |entity| from_entity(entity) }.first
      end

      def from_entity(entity)
        instance = self.new
        instance.id = entity.key.id
        entity.properties.to_hash.each do |name, value|
          instance.send "#{name}=", value
        end
        instance
      end

      def search(options = {})
        query =
          if options[:query]
            options[:query]
          else
            query = Gcloud::Datastore::Query.new
            query.kind(self.to_s)
            query.limit(options[:limit]) if options[:limit]
            query.cursor(options[:cursor]) if options[:cursor]
            query
          end

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

    def destroy
      entity = to_entity
      IseshimaStore::Connection.current.delete(entity)
    end

    def to_entity
      entity = Gcloud::Datastore::Entity.new
      entity.key = Gcloud::Datastore::Key.new(self.class.to_s, id)
      self.class.properties.each do |property|
        property = property.to_s
        entity[property] = send(property)
      end
      entity
    end
  end
end
