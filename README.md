# TeeTimes Pro ⛳

Golf course tee time management SaaS platform. Built for course operators who need modern booking, real-time tee sheet management, and integrated payments.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **API** | Rails 8, Ruby 3.3, GraphQL (graphql-ruby) |
| **Frontend** | React 18, TypeScript, Vite, Tailwind CSS |
| **Data** | PostgreSQL 16, Redis 7 |
| **Background Jobs** | Sidekiq + sidekiq-cron |
| **Payments** | Stripe Connect |
| **SMS** | Twilio |
| **Real-time** | ActionCable (WebSocket) |
| **Auth** | Devise + JWT |
| **Testing** | RSpec, FactoryBot, Vitest, Storybook |
| **Infra** | Docker Compose, GitHub Actions CI |

## Architecture

- **Multi-tenant** — Organizations (golf courses) are the tenant boundary. Every query is scoped to the current organization.
- **Service objects** — All business logic lives in `app/services/`. Controllers and GraphQL mutations are thin wrappers that call services.
- **ServiceResult** — Services return `ServiceResult` objects (never raise for business logic errors).
- **GraphQL API** — Single `/graphql` endpoint. Types mirror models, mutations mirror service objects.
- **Pundit authorization** — Policy objects enforce access control at the service/mutation layer.

## Getting Started

### Docker (recommended)

```bash
# Clone and configure
git clone https://github.com/AgentClaude/teetimepro.git
cd teetimepro
cp .env.example .env

# Development mode (hot-reload for API + frontend)
bin/docker-dev up

# Or production-like mode
docker compose up --build

# Services:
#   API:      http://localhost:3003
#   Frontend: http://localhost:3004
#   Postgres: localhost:5434
#   Redis:    localhost:6381
```

### Docker Dev Commands

```bash
bin/docker-dev up           # Start all services with hot-reload
bin/docker-dev down         # Stop all services
bin/docker-dev build        # Rebuild containers
bin/docker-dev logs api     # Tail logs for a service
bin/docker-dev console      # Rails console
bin/docker-dev dbconsole    # PostgreSQL console
bin/docker-dev rspec        # Run API tests
bin/docker-dev seed         # Seed the database
bin/docker-dev reset        # Reset database (drop + create + migrate + seed)
bin/docker-dev sh api       # Shell into a container
```

### Local Development (without Docker)

#### API (Rails)
```bash
cd api
bundle install
bundle exec rails db:create db:migrate db:seed
bundle exec rails server -p 3003
bundle exec rspec              # Run tests
bundle exec sidekiq            # Background jobs
```

#### Frontend (React)
```bash
cd web
npm install
npm run dev                    # Vite dev server on :3004
npm run codegen                # Generate GraphQL types
npm run storybook              # Component explorer
npm run test                   # Vitest
npx tsc --noEmit               # Type check
```

## Key Patterns

### Service Objects
```ruby
# app/services/bookings/create_booking_service.rb
result = Bookings::CreateBookingService.call(
  organization: org,
  tee_time: tee_time,
  user: user,
  players_count: 4,
  payment_method_id: "pm_xxx"
)

if result.success?
  result.data[:booking]  # => Booking instance
else
  result.errors          # => ["Tee time is no longer available"]
end
```

### GraphQL Mutations → Services
```ruby
# Mutations are thin — they call services
class Mutations::CreateBooking < Mutations::BaseMutation
  def resolve(**args)
    result = Bookings::CreateBookingService.call(**args)
    # ...
  end
end
```

### RSpec Conventions
- Factories in `spec/factories/` (match model names)
- Service specs in `spec/services/<domain>/`
- GraphQL specs in `spec/graphql/mutations/`
- Use `AuthHelper` and `GraphQLHelper` from `spec/support/`

## Documentation

- [Product Requirements (PRD)](docs/prd/tee-time-platform.md)
- [Competitive Analysis](docs/discovery/tee-time-platform/COMPETITORS.md)
- [Discovery Brief](docs/discovery/tee-time-platform/BRIEF.md)
- [Roadmap](ROADMAP.md)
- [Agent Conventions](AGENTS.md)

## License

Proprietary — All rights reserved.
