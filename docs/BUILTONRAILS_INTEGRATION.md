# Builtonrails Integration with Shorttags

## Configuration

```ruby
# config/initializers/shorttags.rb
Shorttags.configure do |config|
  config.api_key = Rails.application.credentials.dig(:shorttags, :api_key)
  config.site_id = "builtonrails"
end
```

## Two Types of Metrics

### 1. `track()` - Additive/Incremental Metrics
Use for events that happen and accumulate over time.

```ruby
# Each call ADDS to the total
Shorttags.track(signups: 1)           # +1 signup
Shorttags.track(page_views: 5)        # +5 page views
Shorttags.track(revenue: 99.00)       # +$99 revenue
```

### 2. `accumulate()` - Absolute/Lifetime Metrics
Use for totals that should reflect current state, not sum over time.

```ruby
# Each call SETS the absolute value (overwrites previous)
Shorttags.accumulate(total_members: User.count)           # Current member count
Shorttags.accumulate(total_projects: Project.count)       # Current project count
Shorttags.accumulate(mrr: Subscription.active.sum(:amount)) # Current MRR
```

## Builtonrails Recommended Metrics

### Lifetime Totals (use `accumulate`)
```ruby
# Call periodically or after relevant changes
Shorttags.accumulate(
  total_members: User.count,
  total_projects: Project.count,
  total_posts: Post.published.count
)
```

### Event Tracking (use `track`)
```ruby
# Call when events happen
Shorttags.signup                           # New user registered
Shorttags.login                            # User logged in
Shorttags.track(project_created: 1)        # New project created
Shorttags.track(post_published: 1)         # New post published
```

## Sync Job Example

```ruby
# app/jobs/sync_lifetime_metrics_job.rb
class SyncLifetimeMetricsJob < ApplicationJob
  def perform
    Shorttags.accumulate(
      total_members: User.count,
      total_projects: Project.count,
      total_posts: Post.published.count
    )
  end
end

# Schedule to run periodically (e.g., every hour)
```

## Key Difference

| Method | Behavior | Use Case |
|--------|----------|----------|
| `track()` | Additive - values sum | Events: signups, page views, purchases |
| `accumulate()` | Absolute - overwrites | Totals: member count, MRR, active users |

## API Endpoints

- `POST /api/notify/:site_id` - For `track()` calls
- `PUT /api/notify/:site_id/accumulators` - For `accumulate()` calls
