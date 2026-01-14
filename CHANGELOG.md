# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.4.0] - 2026-01-14

### Added

- `Shorttags.accumulate` for setting absolute accumulator values (overwrites, not additive)
- Use for lifetime totals that should reflect current state: `Shorttags.accumulate(total_users: User.count)`
- New endpoint: `PUT /api/notify/:site_id/accumulators`

## [0.1.0] - 2025-01-07

### Added

- Initial release
- `Shorttags.track` for custom metrics tracking
- `Shorttags.signup` for tracking user registrations
- `Shorttags.payment` for tracking payments and revenue
- `Shorttags.event` for tracking custom events
- Event classes: `UserRegistered`, `UserPaid`, `MetricRecorded`
- Configuration via `Shorttags.configure` block
- HTTP client with timeout support and error handling
