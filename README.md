# Shorttags Ruby Client

Simple, lightweight Ruby gem for tracking metrics with [Shorttags](https://shorttags.com).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'shorttags-rb'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install shorttags-rb
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

### Track Payments & Revenue

```ruby
# Track a payment with amount
Shorttags.payment(99.00)

# Track with MRR and additional data
Shorttags.payment(99.00, mrr: 99.00, plan: "pro")

# Track annual payment
Shorttags.payment(999.00, plan: "enterprise", billing: "annual")
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

### Using Event Classes Directly

```ruby
# For more control, use event classes directly
Shorttags::Events::UserRegistered.track(plan: "pro")
Shorttags::Events::UserPaid.track(amount: 99.00, mrr: 99.00)
Shorttags::Events::MetricRecorded.track(custom_metric: 42)
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

### Track payments in controller

```ruby
class PaymentsController < ApplicationController
  def create
    @payment = current_user.payments.create!(payment_params)

    Shorttags.payment(@payment.amount, mrr: @payment.mrr)

    redirect_to dashboard_path
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
