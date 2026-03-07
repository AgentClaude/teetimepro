module Types
  class MutationType < Types::BaseObject
    field :create_booking, mutation: Mutations::CreateBooking
    field :cancel_booking, mutation: Mutations::CancelBooking
    field :update_booking, mutation: Mutations::UpdateBooking
    field :create_payment_intent, mutation: Mutations::CreatePaymentIntent
    field :create_course, mutation: Mutations::CreateCourse
    field :update_tee_time, mutation: Mutations::UpdateTeeTime
    field :update_course_voice_config, mutation: Mutations::UpdateCourseVoiceConfig
    field :create_sms_campaign, mutation: Mutations::CreateSmsCampaign
    field :send_sms_campaign, mutation: Mutations::SendSmsCampaign
    field :cancel_sms_campaign, mutation: Mutations::CancelSmsCampaign
    field :update_customer, mutation: Mutations::UpdateCustomer
    field :create_tournament, mutation: Mutations::CreateTournament
    field :update_tournament, mutation: Mutations::UpdateTournament
    field :register_for_tournament, mutation: Mutations::RegisterForTournament
    field :withdraw_from_tournament, mutation: Mutations::WithdrawFromTournament
    
    # Accounting integrations
    field :connect_accounting_integration, mutation: Mutations::ConnectAccountingIntegration
    field :disconnect_accounting_integration, mutation: Mutations::DisconnectAccountingIntegration
    field :sync_accounting_data, mutation: Mutations::SyncAccountingData
    field :configure_accounting_mapping, mutation: Mutations::ConfigureAccountingMapping
    
    # Calendar integrations
    field :connect_google_calendar, mutation: Mutations::ConnectGoogleCalendar
    field :disconnect_calendar, mutation: Mutations::DisconnectCalendar
    field :toggle_calendar_sync, mutation: Mutations::ToggleCalendarSync
  end
end
