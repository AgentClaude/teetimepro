# frozen_string_literal: true

class TeeSheets::SearchTeeTimesService < ApplicationService
  attr_accessor :organization, :date, :start_date, :end_date, :players,
                :time_preference, :course_id, :status, :limit

  validates :organization, presence: true

  def call
    return validation_failure(self) unless valid?

    query = build_query
    tee_times = query.limit(effective_limit).to_a

    if tee_times.empty? && date.present?
      alternatives = find_alternatives
      if alternatives.any?
        return success(
          tee_times: [],
          alternatives: alternatives,
          message: "No times available on #{date}. Here are some alternatives."
        )
      end
    end

    success(tee_times: tee_times)
  end

  private

  def effective_limit
    limit.present? && limit.positive? ? limit : 20
  end

  def build_query
    query = base_scope

    query = apply_course_filter(query)
    query = apply_date_filters(query)
    query = apply_players_filter(query)
    query = apply_time_preference_filter(query)
    query = apply_status_filter(query)

    query.order("tee_sheets.date", "tee_times.starts_at")
  end

  def base_scope
    TeeTime.joins(tee_sheet: :course)
           .where(courses: { organization_id: organization.id })
  end

  def apply_course_filter(query)
    return query unless course_id.present?

    query.where(courses: { id: course_id })
  end

  def apply_date_filters(query)
    if date.present?
      parsed_date = Date.parse(date.to_s)
      query = query.where(tee_sheets: { date: parsed_date })
    elsif start_date.present? || end_date.present?
      if start_date.present?
        query = query.where("tee_sheets.date >= ?", Date.parse(start_date.to_s))
      end
      if end_date.present?
        query = query.where("tee_sheets.date <= ?", Date.parse(end_date.to_s))
      end
    end

    query
  end

  def apply_players_filter(query)
    return query unless players.present? && players.positive?

    query.where(status: [:available, :partially_booked])
         .where("tee_times.max_players - tee_times.booked_players >= ?", players)
  end

  def apply_time_preference_filter(query)
    return query unless time_preference.present?

    reference_date = resolve_reference_date
    tz = organization_timezone

    range = time_range_for_preference(time_preference)
    return query unless range

    start_time = reference_date.in_time_zone(tz).change(hour: range[:start])
    end_time = reference_date.in_time_zone(tz).change(hour: range[:end])
    query.where(tee_times: { starts_at: start_time..end_time })
  end

  def apply_status_filter(query)
    return query unless status.present?

    case status.to_s
    when "available"
      query.where(tee_times: { status: [:available, :partially_booked] })
    when "fully_booked"
      query.where(tee_times: { status: :fully_booked })
    when "blocked"
      query.where(tee_times: { status: [:blocked, :maintenance] })
    else
      query
    end
  end

  def time_range_for_preference(preference)
    case preference.to_s
    when "early_morning" then { start: 6, end: 8 }
    when "morning"       then { start: 7, end: 11 }
    when "midday"        then { start: 11, end: 13 }
    when "afternoon"     then { start: 12, end: 16 }
    when "twilight"      then { start: 15, end: 18 }
    else
      hour = preference.to_i
      if hour.between?(5, 20)
        { start: [hour - 1, 5].max, end: [hour + 1, 20].min }
      end
    end
  end

  def find_alternatives
    alternatives = []

    # Try adjacent days (±1 day)
    parsed_date = Date.parse(date.to_s)
    [-1, 1].each do |offset|
      alt_date = parsed_date + offset.days
      alt_query = base_scope.where(tee_sheets: { date: alt_date })
      alt_query = apply_players_filter(alt_query)
      alt_query = apply_time_preference_filter_for_date(alt_query, alt_date)
      alt_query = apply_course_filter(alt_query)
      results = alt_query.order("tee_times.starts_at").limit(3).to_a

      alternatives.concat(results) if results.any?
    end

    # Try wider time window on the same day (±1 hour from preference)
    if time_preference.present?
      wider_query = base_scope.where(tee_sheets: { date: parsed_date })
      wider_query = apply_players_filter(wider_query)
      wider_query = apply_course_filter(wider_query)
      wider_query = apply_wider_time_filter(wider_query, parsed_date)
      wider_results = wider_query.order("tee_times.starts_at").limit(3).to_a

      alternatives.concat(wider_results)
    end

    alternatives.uniq(&:id).first(5)
  end

  def apply_time_preference_filter_for_date(query, target_date)
    return query unless time_preference.present?

    tz = organization_timezone
    range = time_range_for_preference(time_preference)
    return query unless range

    start_time = target_date.in_time_zone(tz).change(hour: range[:start])
    end_time = target_date.in_time_zone(tz).change(hour: range[:end])
    query.where(tee_times: { starts_at: start_time..end_time })
  end

  def apply_wider_time_filter(query, target_date)
    tz = organization_timezone
    range = time_range_for_preference(time_preference)
    return query unless range

    wider_start = [range[:start] - 1, 5].max
    wider_end = [range[:end] + 1, 20].min

    start_time = target_date.in_time_zone(tz).change(hour: wider_start)
    end_time = target_date.in_time_zone(tz).change(hour: wider_end)

    # Exclude the original range so we only get truly alternative times
    original_start = target_date.in_time_zone(tz).change(hour: range[:start])
    original_end = target_date.in_time_zone(tz).change(hour: range[:end])

    query.where(tee_times: { starts_at: start_time..end_time })
         .where.not(tee_times: { starts_at: original_start..original_end })
  end

  def resolve_reference_date
    if date.present?
      Date.parse(date.to_s)
    elsif start_date.present?
      Date.parse(start_date.to_s)
    else
      Date.current
    end
  end

  def organization_timezone
    organization.try(:timezone) || "UTC"
  end
end
