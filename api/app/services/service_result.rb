class ServiceResult
  attr_reader :data, :errors

  def initialize(success:, data: {}, errors: [])
    @success = success
    @data = data.is_a?(Hash) ? OpenStruct.new(data) : data
    @errors = Array(errors)
  end

  def success?
    @success
  end

  def failure?
    !success?
  end

  def error_message
    errors.first
  end

  def error_messages
    errors.join(", ")
  end

  def [](key)
    data.respond_to?(key) ? data.send(key) : nil
  end

  # Delegate unknown methods to data (OpenStruct) for convenience
  # Returns nil for missing getter methods (allows safe chaining on failure results)
  def method_missing(method, *args, &block)
    if data.respond_to?(method)
      data.send(method, *args, &block)
    elsif method.to_s.end_with?('=') || method.to_s.end_with?('!') || block
      super
    else
      nil
    end
  end

  def respond_to_missing?(method, include_private = false)
    data.respond_to?(method, include_private) || !method.to_s.end_with?('=', '!') || super
  end
end
