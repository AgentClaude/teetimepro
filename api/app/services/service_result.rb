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
end
