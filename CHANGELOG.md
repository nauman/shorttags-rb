# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
