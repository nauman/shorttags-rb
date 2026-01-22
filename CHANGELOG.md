# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.5.0] - 2026-01-22

### Added

- `Shorttags.action` for sending actionable metrics that show in dashboard for approve/reject
- `Shorttags::Callbacks` module for handling webhook action callbacks in Rails controllers
- `Shorttags::Callbacks::Callback` class with `approved?`, `rejected?`, payload access
- `parse_callback(request)` helper for parsing incoming callbacks
- `handle_shorttags_callback` helper for easy Rails controller integration
- Comprehensive test coverage for new features (71 total tests)

### Example Usage

```ruby
# Send actionable metric
Shorttags.action(:pending_site, 1, {
  site_id: site.id,
  title: site.title,
  user_email: user.email
})

# Handle callbacks in Rails controller
class ShorttagsCallbacksController < ApplicationController
  include Shorttags::Callbacks
  skip_before_action :verify_authenticity_token

  def create
    handle_shorttags_callback do |callback|
      site = Site.find(callback["site_id"])
      callback.approved? ? site.approve! : site.reject!
    end
  end
end
```

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
