module Types
  class BaseObject < GraphQL::Schema::Object
    field_class Types::BaseField

    def current_user
      context[:current_user]
    end

    def current_organization
      context[:current_organization]
    end

    def require_auth!
      raise GraphQL::ExecutionError, "Not authenticated" unless current_user
      raise GraphQL::ExecutionError, "No organization" unless current_organization

      current_organization
    end
  end
end
