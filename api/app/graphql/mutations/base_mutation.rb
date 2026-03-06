module Mutations
  class BaseMutation < GraphQL::Schema::Mutation
    argument_class Types::BaseArgument
    field_class Types::BaseField

    private

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

    def require_role!(minimum_role)
      require_auth!
      roles = User.roles
      unless roles[current_user.role] >= roles[minimum_role.to_s]
        raise GraphQL::ExecutionError, "Insufficient permissions"
      end
    end

    def authorize(record, query = nil)
      raise GraphQL::ExecutionError, "Not authenticated" unless current_user

      query ||= default_query_for_action
      policy = Pundit.policy!(current_user, record)

      unless policy.public_send(query)
        raise GraphQL::ExecutionError,
              "Not authorized to #{query.to_s.chomp('?')} this #{record.class.name.underscore.humanize.downcase}"
      end

      record
    end

    def policy_scope(scope)
      raise GraphQL::ExecutionError, "Not authenticated" unless current_user

      Pundit.policy_scope!(current_user, scope)
    end

    def default_query_for_action
      case self.class.name.demodulize
      when /^Create/ then :create?
      when /^Update/ then :update?
      when /^Delete/, /^Cancel/ then :destroy?
      else :show?
      end
    end
  end
end
