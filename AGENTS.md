# AGENTS.md — TeeTimes Pro

## Architecture Rules (NON-NEGOTIABLE)
1. **Controllers ONLY call service objects** — no business logic in controllers
2. **GraphQL mutations ONLY call service objects** — mutations are thin wrappers
3. **Service objects return ServiceResult** — never raise for business logic errors
4. **Multi-tenant scoping via Organization** — every query scoped to current org
5. **All new features need RSpec tests** — services, models, and GraphQL specs
6. **TypeScript strict mode** — no `any` types except generated code
7. **Storybook for all UI components** — every component gets a story

## Conventions
- Service objects: `app/services/<domain>/<action>_service.rb`, called via `.call(**args)`
- Factories: match model names, in `spec/factories/`
- GraphQL: types mirror models, mutations mirror service objects
- Frontend: feature-based folders under `components/`, shared UI in `components/ui/`
- All environment config via `.env` — never hardcode

## Git Workflow
- Feature branches off `main`
- Use worktrees for parallel agents: `git worktree add ../teetimepro-worktrees/<name> -b <branch>`
- PRs require passing CI
- Main stays deployable

## Pre-commit Checklist
1. `cd api && bundle install`
2. `cd api && bundle exec rspec --fail-fast`
3. `cd web && npx tsc --noEmit`
4. `cd web && npx eslint src/ --fix`
