class CallRecording < ApplicationRecord
  belongs_to :organization
  belongs_to :voice_call_log, optional: true
  has_many :call_transcriptions, dependent: :destroy

  validates :call_sid, presence: true
  validates :recording_sid, presence: true, uniqueness: true
  validates :recording_url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp }
  validates :duration_seconds, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true, inclusion: { in: %w[pending processing completed failed] }
  validates :format, presence: true

  scope :for_organization, ->(org) { where(organization: org) }
  scope :recent, -> { order(created_at: :desc) }
  scope :completed, -> { where(status: 'completed') }
  scope :pending, -> { where(status: 'pending') }
  scope :failed, -> { where(status: 'failed') }

  before_validation :calculate_word_count, on: :update

  def transcribed?
    call_transcriptions.where(status: 'completed').exists?
  end

  def latest_transcription
    call_transcriptions.where(status: 'completed').order(created_at: :desc).first
  end

  def mark_completed!
    update!(status: 'completed')
  end

  def mark_failed!(error_message = nil)
    update!(status: 'failed')
  end

  private

  def calculate_word_count
    # This is a placeholder - in a real implementation we might extract this
    # from the audio file or transcription
  end
end