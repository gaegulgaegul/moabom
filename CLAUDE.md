# CLAUDE.md

## Project Overview

**모아봄 (MoaBom)**: 가족 아기 사진첩 앱
- Rails 8.1 + Hotwire (Turbo + Stimulus) + TailwindCSS
- SQLite (Solid Cache/Queue/Cable)
- Turbo Native (iOS/Android)

## Commands

```bash
# Development
bin/dev                    # Start dev server (foreman)
rails server               # Start Rails server only
rails console              # Rails console

# Database
rails db:migrate           # Run migrations
rails db:seed              # Seed data
rails db:reset             # Drop, create, migrate, seed

# Testing
rails test                 # Run all tests
rails test test/models     # Run model tests
rails test:system          # Run system tests

# Code Quality
rubocop                    # Lint Ruby code
rubocop -a                 # Auto-fix issues

# Assets
rails tailwindcss:build    # Build TailwindCSS
rails tailwindcss:watch    # Watch TailwindCSS changes
```

## Project Structure

```
app/
├── controllers/           # Thin controllers, delegate to services
├── models/                # Business logic, validations, scopes
├── services/              # Complex operations (PhotoUploadService)
├── jobs/                  # Background jobs (ProcessPhotoJob)
├── views/                 # ERB templates with Turbo Frames
└── javascript/controllers # Stimulus controllers

docs/
├── PRD.md                 # Product requirements
├── ARCHITECTURE.md        # System architecture
├── API_DESIGN.md          # API endpoints
├── WIREFRAME.md           # Screen designs
└── guides/                # Development guides
    ├── CODING_GUIDE.md
    ├── CONVENTIONS.md
    ├── COMMIT_GUIDE.md
    └── ARCHITECTURE_GUIDE.md
```

## Code Style

- 2 spaces indentation, no tabs
- snake_case for methods/variables, PascalCase for classes
- Controllers: thin, delegate to services
- Models: validations, associations, scopes, domain logic only
- Services: complex business logic, return Result objects
- Prefer `&.` over `try`, guard clauses over nested ifs

## TDD Workflow

Follow plan.md for TDD cycle:
1. **RED**: Write failing test first
2. **GREEN**: Minimum code to pass
3. **REFACTOR**: Improve structure (no behavior change)

Update plan.md checkboxes after each phase.

## Commit Rules

Format: `<type>(<scope>): <subject>`

Types: feat, fix, refactor, test, docs, chore, perf

**IMPORTANT**: Never mix structural (refactor) and behavioral (feat/fix) changes in one commit.

## Key Patterns

- N+1 prevention: Always use `includes` for associations
- Strong params: Whitelist all parameters
- Authorization: Access resources through `current_user.families.find(id)`
- Turbo Frames: Use `turbo_frame_tag dom_id(object)` for partials
- Background jobs: Use for uploads, notifications, processing

## Before Committing

1. `rails test` - All tests pass
2. `rubocop` - No lint errors
3. No debug code (puts, binding.pry, debugger)
4. No commented-out code
5. **설계 문서 확인**:
   - PRD.md의 해당 기능 요구사항 충족
   - API_DESIGN.md의 엔드포인트 규격 준수
   - ARCHITECTURE.md의 레이어 책임 준수

## Reference Docs

For detailed information, read the relevant guide before starting work:
- Architecture decisions: `docs/guides/ARCHITECTURE_GUIDE.md`
- Coding standards: `docs/guides/CODING_GUIDE.md`
- Conventions: `docs/guides/CONVENTIONS.md`
- Commit format: `docs/guides/COMMIT_GUIDE.md`
