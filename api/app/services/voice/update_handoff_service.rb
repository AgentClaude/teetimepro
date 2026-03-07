module Voice
  class UpdateHandoffService < ApplicationService
    attr_accessor :handoff, :status, :staff_name, :resolution_notes, :wait_seconds

    validates :handoff, presence: true
    validates :status, presence: true, inclusion: { in: VoiceHandoff.statuses.keys }

    def call
      return validation_failure(self) unless valid?

      # Validate status transition
      unless valid_status_transition?
        return failure(["Invalid status transition from #{handoff.status} to #{status}"])
      end

      # Validate required fields for specific statuses
      validation_error = validate_status_requirements
      return failure([validation_error]) if validation_error

      ActiveRecord::Base.transaction do
        update_handoff
        set_timestamps
        
        handoff.save!
      end

      success(handoff: handoff, updated: true)

    rescue ActiveRecord::RecordInvalid => e
      failure(e.record.errors.full_messages)
    rescue StandardError => e
      Rails.logger.error "Voice handoff update failed: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      failure(["Failed to update handoff: #{e.message}"])
    end

    private

    def update_handoff
      handoff.assign_attributes(update_attributes)
    end

    def update_attributes
      attrs = { status: status }
      
      attrs[:staff_name] = staff_name.strip if staff_name.present?
      attrs[:resolution_notes] = resolution_notes.strip if resolution_notes.present?
      attrs[:wait_seconds] = wait_seconds if wait_seconds.present?
      
      attrs
    end

    def set_timestamps
      now = Time.current
      
      case status
      when 'connected'
        handoff.connected_at ||= now
        # Calculate wait time if not provided and we have both timestamps
        if wait_seconds.blank? && handoff.started_at && handoff.connected_at
          handoff.wait_seconds = (handoff.connected_at - handoff.started_at).to_i
        end
      when 'completed', 'missed', 'cancelled'
        handoff.completed_at ||= now
        # If going directly to completed without connected, set both timestamps
        if handoff.connected_at.blank? && %w[completed missed].include?(status)
          handoff.connected_at = handoff.started_at
          handoff.wait_seconds = 0
        end
      end
    end

    def valid_status_transition?
      current_status = handoff.status
      target_status = status
      
      # Define valid transitions
      transitions = {
        'pending' => %w[connected missed cancelled],
        'connected' => %w[completed missed cancelled],
        'completed' => [], # Terminal state
        'missed' => [], # Terminal state  
        'cancelled' => [] # Terminal state
      }
      
      transitions[current_status]&.include?(target_status)
    end

    def validate_status_requirements
      case status
      when 'connected'
        return "Staff name is required when marking as connected" if staff_name.blank?
      when 'completed'
        return "Resolution notes are required when marking as completed" if resolution_notes.blank?
      when 'missed'
        return "Resolution notes are required when marking as missed" if resolution_notes.blank?
      when 'cancelled'
        return "Resolution notes are required when marking as cancelled" if resolution_notes.blank?
      end
      
      nil
    end
  end
end