require 'iseshima_store/query_methods'
require 'iseshima_store/where_clause'
require 'forwardable'

module IseshimaStore
  class Relation
    extend Forwardable
    include Enumerable
    include IseshimaStore::QueryMethods
    attr_accessor :where_clause
    def_delegators :to_a, :first, :last

    def initialize(klass)
      @klass = klass
      @where_clause = IseshimaStore::WhereClause.new(@klass)
    end

    def spawn
      clone
    end

    def each
      to_a.each { |obj| yield obj }
    end
  end
end
