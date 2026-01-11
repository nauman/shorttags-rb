# Shorttags Ruby Client

Simple, lightweight Ruby gem for tracking metrics with [Shorttags](https://shorttags.com).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'shorttags-rb', github: 'nauman/shorttags-rb'
```

And then execute:

```bash
$ bundle install
```

## Configuration

### Rails

Create an initializer `config/initializers/shorttags.rb`:

```ruby
Shorttags.configure do |config|
  config.api_key = Rails.application.credentials.shorttags_api_key
  config.site_id = "your-site-id"
end
```

### Plain Ruby

```ruby
require 'shorttags'

Shorttags.configure do |config|
  config.api_key = ENV['SHORTTAGS_API_KEY']
  config.site_id = "your-site-id"
end
```

## Usage

### Track Custom Metrics

```ruby
# Track any custom metrics
Shorttags.track(page_views: 1, unique_visitors: 1)

# Track multiple metrics at once
Shorttags.track(
  api_calls: 5,
  errors: 1,
  response_time_avg: 245
)
```

### Track Signups

```ruby
# Simple signup tracking
Shorttags.signup

# With additional data
Shorttags.signup(plan: "free", source: "organic")
```

### Track Logins

```ruby
# Simple login tracking
Shorttags.login

# With additional data
Shorttags.login(method: "magic_link", user_id: 123)
```

### Track Payments & Revenue

```ruby
# Track a payment with amount
Shorttags.payment(99.00)

# Track with MRR and additional data
Shorttags.payment(99.00, mrr: 99.00, plan: "pro")

# Track annual payment
Shorttags.payment(999.00, plan: "enterprise", billing: "annual")
```

### Track Subscriptions

```ruby
# Track subscription tier change
Shorttags.subscription("pro")

# With MRR
Shorttags.subscription("pro", mrr: 29.00, previous_tier: "free")
```

### Track Feature Usage

```ruby
# Track feature usage
Shorttags.feature_used(:export)
Shorttags.feature_used(:api, endpoint: "/metrics")
Shorttags.feature_used(:dashboard, views: 5)
```

### Track Errors

```ruby
# Track error occurrences
Shorttags.error(:validation)
Shorttags.error(:api, message: "Rate limit exceeded")
Shorttags.error(:payment, provider: "stripe")
```

### Track Custom Events

```ruby
# Simple event (value defaults to 1)
Shorttags.event(:file_uploads)

# Event with custom value
Shorttags.event(:api_calls, 5)

# Event with additional metrics
Shorttags.event(:orders, 1, revenue: 150.00)
```

### Track Analytics (Pageviews, Visitors, Sessions)

```ruby
# Track pageviews
Shorttags.pageview
Shorttags.pageview(1, path: "/pricing")
Shorttags.pageview(5, unique_pageviews: 3)

# Track visitors
Shorttags.visitor
Shorttags.visitor(1, source: "google")
Shorttags.visitor(10, country: "US")

# Track sessions
Shorttags.session
Shorttags.session(1, duration: 120)
Shorttags.session(1, bounce: true)
```

### Using Event Classes Directly

```ruby
# For more control, use event classes directly
Shorttags::Events::UserRegistered.track(plan: "pro")
Shorttags::Events::UserLoggedIn.track(method: "oauth")
Shorttags::Events::UserPaid.track(amount: 99.00, mrr: 99.00)
Shorttags::Events::SubscriptionChanged.track(tier: "pro", mrr: 29.00)
Shorttags::Events::FeatureUsed.track(feature: :export)
Shorttags::Events::ErrorOccurred.track(type: :validation)
Shorttags::Events::MetricRecorded.track(custom_metric: 42)
Shorttags::Events::PageviewTracked.track(count: 1, path: "/home")
Shorttags::Events::VisitorTracked.track(count: 1, source: "google")
Shorttags::Events::SessionTracked.track(count: 1, duration: 120)
```

## Rails Integration Examples

### Track signups in User model

```ruby
class User < ApplicationRecord
  after_create_commit :track_signup

  private

  def track_signup
    Shorttags.signup(plan: plan_name)
  end
end
```

### Track logins in SessionsController

```ruby
class SessionsController < ApplicationController
  def create
    user = User.authenticate(params[:email], params[:password])
    if user
      sign_in(user)
      Shorttags.login(method: "password")
      redirect_to dashboard_path
    end
  end
end
```

### Track payments in controller

```ruby
class PaymentsController < ApplicationController
  def create
    @payment = current_user.payments.create!(payment_params)

    Shorttags.payment(@payment.amount, mrr: @payment.mrr, plan: current_user.plan)

    redirect_to dashboard_path
  end
end
```

### Track errors with rescue_from

```ruby
class ApplicationController < ActionController::Base
  rescue_from StandardError do |exception|
    Shorttags.error(:unhandled, message: exception.message)
    raise exception
  end
end
```

### Background job tracking

```ruby
class TrackMetricsJob < ApplicationJob
  def perform(metrics)
    Shorttags.track(metrics)
  end
end

# Call from anywhere
TrackMetricsJob.perform_later(daily_active_users: 150)
```

## API Reference

| Method | Description | Example |
|--------|-------------|---------|
| `track(metrics)` | Track raw metrics hash | `Shorttags.track(views: 100)` |
| `signup(extra = {})` | Track user signup | `Shorttags.signup(plan: "pro")` |
| `login(extra = {})` | Track user login | `Shorttags.login` |
| `payment(amount, extra = {})` | Track payment/revenue | `Shorttags.payment(99.00)` |
| `subscription(tier, extra = {})` | Track subscription change | `Shorttags.subscription("pro")` |
| `feature_used(feature, extra = {})` | Track feature usage | `Shorttags.feature_used(:export)` |
| `error(type, extra = {})` | Track error occurrence | `Shorttags.error(:api)` |
| `event(name, value = 1, extra = {})` | Track custom event | `Shorttags.event(:orders, 5)` |
| `pageview(count = 1, extra = {})` | Track pageviews | `Shorttags.pageview(1, path: "/")` |
| `visitor(count = 1, extra = {})` | Track visitors | `Shorttags.visitor` |
| `session(count = 1, extra = {})` | Track sessions | `Shorttags.session(1, duration: 60)` |

## Error Handling

```ruby
begin
  Shorttags.track(signups: 1)
rescue Shorttags::Client::ConfigurationError => e
  Rails.logger.error "Shorttags not configured: #{e.message}"
rescue Shorttags::Client::ApiError => e
  Rails.logger.error "Shorttags API error: #{e.message}"
end
```

## Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `api_key` | `nil` | Your Shorttags API key (required) |
| `site_id` | `nil` | Your site identifier (required) |
| `base_url` | `https://shorttags.com` | API base URL |
| `timeout` | `30` | Request timeout in seconds |
| `open_timeout` | `10` | Connection timeout in seconds |

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

```bash
git clone https://github.com/nauman/shorttags-rb.git
cd shorttags-rb
bin/setup
rake spec
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nauman/shorttags-rb.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
