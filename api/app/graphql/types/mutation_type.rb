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
    field :initiate_voice_handoff, mutation: Mutations::InitiateVoiceHandoff
    field :update_voice_handoff, mutation: Mutations::UpdateVoiceHandoff
    field :create_sms_campaign, mutation: Mutations::CreateSmsCampaign
    field :send_sms_campaign, mutation: Mutations::SendSmsCampaign
    field :cancel_sms_campaign, mutation: Mutations::CancelSmsCampaign
    field :create_email_campaign, mutation: Mutations::CreateEmailCampaign
    field :send_email_campaign, mutation: Mutations::SendEmailCampaign
    field :cancel_email_campaign, mutation: Mutations::CancelEmailCampaign
    field :update_customer, mutation: Mutations::UpdateCustomer
    field :create_tournament, mutation: Mutations::CreateTournament
    field :update_tournament, mutation: Mutations::UpdateTournament
    field :register_for_tournament, mutation: Mutations::RegisterForTournament
    field :withdraw_from_tournament, mutation: Mutations::WithdrawFromTournament
    field :record_tournament_score, mutation: Mutations::RecordTournamentScore
    field :define_tournament_prizes, mutation: Mutations::DefineTournamentPrizes
    field :finalize_tournament_results, mutation: Mutations::FinalizeTournamentResults
    
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

    # Member account charging
    field :charge_member_account, mutation: Mutations::ChargeMemberAccount
    field :void_member_charge, mutation: Mutations::VoidMemberCharge
    field :charge_fnb_tab_to_member, mutation: Mutations::ChargeFnbTabToMember

    # Tee Sheet integrations
    field :create_turn_order, mutation: Mutations::CreateTurnOrder

    # POS
    field :create_pos_product, mutation: Mutations::CreatePosProduct
    field :update_pos_product, mutation: Mutations::UpdatePosProduct
    field :lookup_pos_product, mutation: Mutations::LookupPosProduct
    field :pos_quick_sale, mutation: Mutations::PosQuickSale

    # Inventory management
    field :adjust_stock, mutation: Mutations::AdjustStock
    field :receive_stock, mutation: Mutations::ReceiveStock

    # Pricing rules
    field :create_pricing_rule, mutation: Mutations::CreatePricingRule
    field :update_pricing_rule, mutation: Mutations::UpdatePricingRule
    field :delete_pricing_rule, mutation: Mutations::DeletePricingRule
    field :calculate_tee_time_price, mutation: Mutations::CalculateTeeTimePrice

    # Marketplace syndication
    field :connect_marketplace, mutation: Mutations::ConnectMarketplace
    field :disconnect_marketplace, mutation: Mutations::DisconnectMarketplace
    field :update_marketplace_settings, mutation: Mutations::UpdateMarketplaceSettings
    field :sync_marketplace, mutation: Mutations::SyncMarketplace

    # Call recordings and transcriptions
    field :request_transcription, mutation: Mutations::RequestTranscription

    # Loyalty program
    field :create_loyalty_program, mutation: Mutations::CreateLoyaltyProgram
    field :earn_points, mutation: Mutations::EarnPoints
    field :redeem_reward, mutation: Mutations::RedeemReward
    field :adjust_points, mutation: Mutations::AdjustPoints
    field :create_reward, mutation: Mutations::CreateReward
    field :update_reward, mutation: Mutations::UpdateReward
  end
end
