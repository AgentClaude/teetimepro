class CallTranscription < ApplicationRecord
  belongs_to :organization
  belongs_to :call_recording
  belongs_to :voice_call_log, optional: true

  validates :transcription_text, presence: true
  validates :confidence_score, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
  validates :language, presence: true
  validates :provider, presence: true, inclusion: { in: %w[deepgram whisper] }
  validates :status, presence: true, inclusion: { in: %w[pending processing completed failed] }
  validates :word_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :duration_seconds, presence: true, numericality: { greater_than: 0 }

  scope :for_organization, ->(org) { where(organization: org) }
  scope :recent, -> { order(created_at: :desc) }
  scope :completed, -> { where(status: 'completed') }
  scope :pending, -> { where(status: 'pending') }
  scope :failed, -> { where(status: 'failed') }
  scope :by_provider, ->(provider) { where(provider: provider) }
  scope :by_language, ->(language) { where(language: language) }
  scope :search_text, ->(query) { where("transcription_text ILIKE ?", "%#{query}%") }

  before_validation :calculate_word_count
  before_validation :calculate_duration_from_recording

  def high_confidence?
    confidence_score >= 0.8
  end

  def medium_confidence?
    confidence_score >= 0.6 && confidence_score < 0.8
  end

  def low_confidence?
    confidence_score < 0.6
  end

  def mark_completed!
    update!(status: 'completed')
  end

  def mark_failed!(error_message = nil)
    update!(status: 'failed')
  end

  def formatted_duration
    minutes = duration_seconds / 60
    seconds = duration_seconds % 60
    "#{minutes}:#{seconds.to_s.rjust(2, '0')}"
  end

  private

  def calculate_word_count
    if transcription_text.present?
      self.word_count = transcription_text.split(/\s+/).length
    end
  end

  def calculate_duration_from_recording
    if call_recording.present? && duration_seconds.nil?
      self.duration_seconds = call_recording.duration_seconds
    end
  end
end