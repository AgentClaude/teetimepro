module Types
  class MutationType < Types::BaseObject
    field :create_booking, mutation: Mutations::CreateBooking
    field :cancel_booking, mutation: Mutations::CancelBooking
    field :create_course, mutation: Mutations::CreateCourse
    field :update_tee_time, mutation: Mutations::UpdateTeeTime
    field :update_course_voice_config, mutation: Mutations::UpdateCourseVoiceConfig
    field :create_sms_campaign, mutation: Mutations::CreateSmsCampaign
    field :send_sms_campaign, mutation: Mutations::SendSmsCampaign
    field :cancel_sms_campaign, mutation: Mutations::CancelSmsCampaign
  end
end
