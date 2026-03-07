module Marketplace
  class AdapterFactory
    ADAPTERS = {
      "golfnow" => "Marketplace::Adapters::GolfnowAdapter",
      "teeoff" => "Marketplace::Adapters::TeeoffAdapter"
    }.freeze

    def self.for(connection)
      adapter_class = ADAPTERS[connection.provider]
      raise ArgumentError, "Unknown marketplace provider: #{connection.provider}" unless adapter_class

      adapter_class.constantize.new(connection)
    end
  end
end
