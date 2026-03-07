module Types
  class MutationType < Types::BaseObject
    # Public mutations (no auth required)
    field :create_public_booking, mutation: Mutations::CreatePublicBooking
    
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
    
    # Golfer segments
    field :create_golfer_segment, mutation: Mutations::CreateGolferSegment
    field :update_golfer_segment, mutation: Mutations::UpdateGolferSegment
    field :delete_golfer_segment, mutation: Mutations::DeleteGolferSegment

    # Calendar integrations
    field :connect_google_calendar, mutation: Mutations::ConnectGoogleCalendar
    field :disconnect_calendar, mutation: Mutations::DisconnectCalendar
    field :toggle_calendar_sync, mutation: Mutations::ToggleCalendarSync
    
    # F&B Tab management
    field :open_fnb_tab, mutation: Mutations::OpenFnbTab
    field :add_fnb_tab_item, mutation: Mutations::AddFnbTabItem
    field :remove_fnb_tab_item, mutation: Mutations::RemoveFnbTabItem
    field :close_fnb_tab, mutation: Mutations::CloseFnbTab
    field :merge_fnb_tabs, mutation: Mutations::MergeFnbTabs
    field :split_fnb_tab, mutation: Mutations::SplitFnbTab
  end
end
