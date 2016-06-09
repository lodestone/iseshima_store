require 'iseshima_store/query_methods'
require 'iseshima_store/where_clause'

module IseshimaStore
  class Relation
    include Enumerable
    include IseshimaStore::QueryMethods
    attr_accessor :where_clause

    def initialize(klass)
      @klass = klass
      @where_clause = IseshimaStore::WhereClause.new
    end

    def spawn
      clone
    end

    def each
      to_a.each { |obj| yield obj }
    end
  end
end
