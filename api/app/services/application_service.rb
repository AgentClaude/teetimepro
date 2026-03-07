# Base service class for TeeTimes Pro
# All service objects inherit from this class and use the .call pattern

class ApplicationService
  include ActiveModel::Validations
  include ActiveModel::AttributeAssignment

  # Class method to create instance and call it
  # Supports both positional hash and keyword arguments:
  #   Service.call(param1: value1, param2: value2)
  #   Service.call({ param1: value1, param2: value2 })
  def self.call(*args, **kwargs)
    if args.length == 1 && args.first.is_a?(Hash) && kwargs.empty?
      new(**args.first).call
    else
      new(*args, **kwargs).call
    end
  end

  def initialize(**args)
    assign_attributes(args)
  end

  # Override in subclasses
  def call
    raise NotImplementedError, "#{self.class.name} must implement #call"
  end

  protected

  # Helper for successful results
  def success(data = {})
    ServiceResult.new(success: true, data: data)
  end

  # Helper for failed results
  def failure(errors = {}, data = {})
    ServiceResult.new(success: false, errors: errors, data: data)
  end

  # Helper for validation failures
  def validation_failure(object)
    failure(object.errors.full_messages)
  end

  # Ensure user belongs to organization
  def authorize_org_access!(user, organization)
    unless user.organization_id == organization.id
      raise AuthorizationError, "User does not belong to this organization"
    end
  end

  # Check if user has minimum role level
  def authorize_role!(user, minimum_role)
    roles = User.roles
    unless roles[user.role] >= roles[minimum_role.to_s]
      raise AuthorizationError, "User does not have sufficient permissions"
    end
  end

  # Current organization helper
  def current_organization
    Organization.current
  end
end
