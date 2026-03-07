module MemberAccounts
  class ViewStatementService < ApplicationService
    attr_accessor :organization, :user, :membership_id, :start_date, :end_date, :page, :per_page

    validates :organization, :user, :membership_id, presence: true

    def call
      return validation_failure(self) unless valid?

      membership = find_membership
      return failure(['Membership not found']) unless membership

      authorize_org_access!(user, organization)

      charges = membership.member_account_charges
        .where.not(status: 'voided')
        .order(created_at: :desc)

      charges = charges.in_date_range(parsed_start_date, parsed_end_date) if date_range_provided?

      paginated = charges.page(current_page).per(items_per_page)

      success(
        membership: membership,
        charges: paginated,
        total_count: charges.count,
        current_balance_cents: membership.account_balance_cents,
        credit_limit_cents: membership.credit_limit_cents,
        available_credit_cents: membership.available_credit_cents,
        period_total_cents: charges.sum(:amount_cents),
        page: current_page,
        per_page: items_per_page,
        total_pages: paginated.total_pages
      )
    rescue StandardError => e
      failure(["Failed to load statement: #{e.message}"])
    end

    private

    def find_membership
      organization.memberships.find_by(id: membership_id)
    end

    def date_range_provided?
      start_date.present? && end_date.present?
    end

    def parsed_start_date
      start_date.is_a?(String) ? Date.parse(start_date) : start_date
    end

    def parsed_end_date
      end_date.is_a?(String) ? Date.parse(end_date) : end_date
    end

    def current_page
      (page || 1).to_i
    end

    def items_per_page
      [(per_page || 25).to_i, 100].min
    end
  end
end
