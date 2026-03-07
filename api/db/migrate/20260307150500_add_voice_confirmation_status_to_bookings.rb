class AddVoiceConfirmationStatusToBookings < ActiveRecord::Migration[7.0]
  def change
    # This migration updates the Booking model to include pending_voice_confirmation status
    # The enum value will be added when we update the model definition
    # Rails enum values are stored as integers, so no database schema change needed
    # Just documenting the intent of adding: pending_voice_confirmation = 5
  end
end