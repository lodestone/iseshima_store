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

    def self.current
      @current ||= Gcloud.datastore(config.project_id)
    end
  end
end
