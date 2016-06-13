require 'gcloud'

module IseshimaStore
  class Connection
    class << self
      attr_accessor :config
    end

    def self.configure(&block)
      self.config ||= OpenStruct.new
      yield(config)
    end

    def self.datastore
      Gcloud.datastore(config.project_id)
    end

    def self.current
      @current ||= Gcloud.datastore(config.project_id)
    end

    def self.clear_connection!
      @current = nil
    end
  end
end
