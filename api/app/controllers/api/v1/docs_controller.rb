class Api::V1::DocsController < Api::V1::BaseController
  skip_before_action :authenticate_api_key!, only: [:index]

  def index
    render json: {
      name: "TeeTimes Pro API",
      version: "1.0",
      description: "RESTful API for TeeTimes Pro golf course management system",
      base_url: request.base_url + "/api/v1",
      authentication: {
        type: "Bearer Token",
        header: "Authorization: Bearer tp_your_api_key_here",
        description: "API keys are organization-scoped and can be managed through your dashboard"
      },
      rate_limits: {
        requests_per_hour: 1000,
        writes_per_hour: 100,
        burst_per_minute: 60,
        headers: {
          limit: "X-RateLimit-Limit",
          remaining: "X-RateLimit-Remaining",
          reset: "X-RateLimit-Reset"
        }
      },
      endpoints: {
        courses: {
          list: "GET /courses - List all courses for your organization",
          show: "GET /courses/{id} - Get course details"
        },
        tee_times: {
          list: "GET /tee_times - List tee times with optional filters",
          show: "GET /tee_times/{id} - Get tee time details",
          filters: {
            course_id: "Filter by course ID",
            start_date: "Filter by start date (YYYY-MM-DD)",
            end_date: "Filter by end date (YYYY-MM-DD)",
            status: "available, fully_booked, or blocked",
            min_players: "Minimum available spots required"
          }
        },
        bookings: {
          list: "GET /bookings - List bookings with optional filters",
          show: "GET /bookings/{id} - Get booking details",
          create: "POST /bookings - Create a new booking",
          cancel: "PATCH /bookings/{id}/cancel - Cancel a booking",
          filters: {
            start_date: "Filter by start date (YYYY-MM-DD)",
            end_date: "Filter by end date (YYYY-MM-DD)",
            status: "confirmed, checked_in, completed, cancelled, no_show",
            course_id: "Filter by course ID",
            confirmation_code: "Find by confirmation code"
          }
        }
      },
      pagination: {
        description: "All list endpoints support pagination",
        parameters: {
          page: "Page number (default: 1)",
          per_page: "Items per page (default: 25, max: 100)"
        },
        response: {
          data: "Array of resources",
          meta: {
            current_page: "Current page number",
            per_page: "Items per page",
            total_pages: "Total number of pages",
            total_count: "Total number of items"
          }
        }
      },
      error_format: {
        error: "Human-readable error message",
        code: "Machine-readable error code",
        details: "Additional error details (validation errors, etc.)"
      },
      status_codes: {
        200 => "OK - Request successful",
        201 => "Created - Resource created successfully",
        400 => "Bad Request - Invalid request parameters",
        401 => "Unauthorized - Invalid or missing API key",
        403 => "Forbidden - Access denied to resource",
        404 => "Not Found - Resource not found",
        422 => "Unprocessable Entity - Validation errors",
        429 => "Too Many Requests - Rate limit exceeded",
        500 => "Internal Server Error - Server error"
      }
    }
  end
end
