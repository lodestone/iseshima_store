require 'forwardable'
require 'gcloud/datastore'
require 'iseshima_store/relation'

#http://googlecloudplatform.github.io/gcloud-ruby/docs/master/Gcloud/Datastore.html

module IseshimaStore
  class EntityNotFound < StandardError; end

  module Base
    def self.included(klass)
      klass.extend SingleForwardable
      klass.extend ClassMethods
      klass.def_delegators :scoping,
        :where,
        :all,
        :first,
        :last,
        :to_a,
        :parent

      klass.instance_eval do
        attr_accessor :id, :created_at, :description, :parent_key
      end
    end

    module ClassMethods
      attr_reader :properties

      def destroy_all
        scoping.each(&:destroy)
      end

      def scoping
        IseshimaStore::Relation.new(self)
      end

      def find(_id)
        datastore = IseshimaStore::Connection.current
        key = datastore.key(self.to_s, _id.to_i)
        entity = datastore.find(key)
        if entity
          from_entity(entity)
        else
          raise EntityNotFound.new("cannot find entity with id #{_id}")
        end
      end

      def attr_properties(*args)
        attr_accessor(*args)
        @properties = args
      end

      def find_by(hash)
        where(hash).first
      end

      def from_entity(entity)
        instance = self.new
        instance.id = entity.key.id
        entity.properties.to_hash.each do |name, value|
          if instance.respond_to?("#{name}=")
            instance.send "#{name}=", value
          end
        end
        instance.parent_key = entity.key.parent
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
      unless self.class.properties
        raise StandardError.new("You have to define attr_properties in your model")
      end

      self.class.properties.each do |property|
        property = property.to_s
        value = send(property)
        if value.is_a?(String)
          value = value.force_encoding('UTF-8')
        end
        entity[property] = value
      end
      entity
    end

    def parent
      return @parent if @parent

      if @parent_key
        klass = @parent_key.kind.constantize
        if klass.include?(IseshimaStore::Base)
          @parent = klass.find(@parent_key.id)
        end
      end
    end

    def key
      to_entity.key
    end
  end
end
