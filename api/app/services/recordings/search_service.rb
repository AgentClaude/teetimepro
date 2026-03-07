module Recordings
  class SearchService < ApplicationService
    attr_accessor :organization, :query, :filters, :page, :per_page

    validates :organization, presence: true

    def call
      return failure(errors: errors.full_messages) if errors.any?

      begin
        build_base_query!
        apply_filters!
        apply_search!
        apply_pagination!
        
        success(
          recordings: @recordings,
          total_count: @total_count,
          current_page: @current_page,
          per_page: @per_page,
          total_pages: @total_pages
        )
      rescue => e
        Rails.logger.error "Failed to search recordings: #{e.message}"
        failure(errors: ["Search failed: #{e.message}"])
      end
    end

    private

    def build_base_query!
      @base_query = organization.call_recordings
                               .includes(:call_transcriptions, :voice_call_log)
                               .order(created_at: :desc)
    end

    def apply_filters!
      @query_scope = @base_query

      if filters.present?
        apply_status_filter!
        apply_date_range_filter!
        apply_duration_filter!
        apply_caller_filter!
      end
    end

    def apply_status_filter!
      if filters[:status].present?
        @query_scope = @query_scope.where(status: filters[:status])
      end
    end

    def apply_date_range_filter!
      if filters[:date_from].present?
        @query_scope = @query_scope.where('created_at >= ?', filters[:date_from])
      end
      
      if filters[:date_to].present?
        @query_scope = @query_scope.where('created_at <= ?', filters[:date_to])
      end
    end

    def apply_duration_filter!
      if filters[:min_duration].present?
        @query_scope = @query_scope.where('duration_seconds >= ?', filters[:min_duration])
      end
      
      if filters[:max_duration].present?
        @query_scope = @query_scope.where('duration_seconds <= ?', filters[:max_duration])
      end
    end

    def apply_caller_filter!
      if filters[:caller].present?
        # This would need to be adjusted based on how caller info is stored
        # For now, we'll search in the voice_call_log
        call_log_ids = organization.voice_call_logs
                                  .where("caller_id ILIKE ? OR caller_name ILIKE ?", 
                                        "%#{filters[:caller]}%", 
                                        "%#{filters[:caller]}%")
                                  .pluck(:id)
        
        @query_scope = @query_scope.where(voice_call_log_id: call_log_ids)
      end
    end

    def apply_search!
      if query.present?
        # Search in transcription text using full-text search
        transcription_ids = organization.call_transcriptions
                                       .search_text(query)
                                       .pluck(:call_recording_id)
        
        @query_scope = @query_scope.where(id: transcription_ids)
      end
    end

    def apply_pagination!
      @page = (page || 1).to_i
      @per_page = [(per_page || 20).to_i, 100].min # Cap at 100 per page
      
      @total_count = @query_scope.count
      @total_pages = (@total_count.to_f / @per_page).ceil
      @current_page = [@page, @total_pages].min
      
      offset = (@current_page - 1) * @per_page
      @recordings = @query_scope.limit(@per_page).offset(offset)
    end
  end
end