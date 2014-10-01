# StepByStep

This gem is largely inspired by the [Railscast on rollouts and degrading](http://railscasts.com/episodes/315-rollout-and-degrade), as well as the [Rollout gem](https://github.com/FetLife/rollout) that is covered in aforementioned Railscast. While very comprehensive, it uses a Redis backend, that might not be desirable to everyone. Though there are some alternatives out there, most of them are either outdated or not as comprehensive as the rollout gem itself.

StepByStep uses ActiveRecord as backend instead and tries to cover as many use cases and features as the original rollout gem. It is easy to use since no additional backend needs to be set up, and adds some helpful methods that shall assist you in rolling out and degrading features reliably.

## Installation

Add this line to your application's Gemfile:

    gem 'step_by_step'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install step_by_step
    
Since StepByStep uses ActiveRecord, you need to create the following migration:

    $ rails g migration create_rollouts name group user_id:integer percentage:integer failure_count:integer
    
Then migrate your database.

## Usage

Let's say you have this new commenting feature that you would like to deploy to production, but you only want a subset of your users to be able to see it. Also, you may want to degrade a feature later, or disable it again altogether.

### Rolling out features

#### Rolling out to a group of users

You can define groups with any custom logic like this:

```ruby
StepByStep::Rollout.define_group :admins do |user|
  user.admin?
end
```

Consider putting this in an initializer, such as `config/initializers/step_by_step.rb`.

Roll out your feature to your group:

```ruby
StepByStep::Rollout.activate_group(:comments, :admins)
```

#### Rolling out to a fraction of users

```ruby
StepByStep::Rollout.activate_percentage(:comments, 20)
end
```

Now 20% of your users can see the comments feature. As in the original gem, this is based on the following algorithm:

```
CRC32(user.id) % 100 < percentage # pseudocode
```

So, for 20%, a feature will be rolled out to users with ids 0, 1, 10, 11, 20, 21, etc. These users also remain as the percentage increases.

#### Rolling out to a specific user

```ruby
StepByStep::Rollout.activate_user(:comments, User.first)
```

Now your first user can see the comments feature.

#### Rolling out to everyone

```ruby
StepByStep::Rollout.activate(:comments)
```

Now everyone can see the comments feature. This is theoretically the same as activating a percentage with value 100 or defining a group with a block that always returns true.

Activating a feature for everyone is common after you have determined that your rollout phase was successful.

### Deactivating features

You can easily deactivate new features depending on your needs.

#### Deactivating a feature for everyone

```ruby
StepByStep::Rollout.deactivate(:comments)
```

Nobody can see your new comments feature anymore.

#### Deactivating a group feature

Your admins shouldn't be able to see the comments anymore? Easy:

```ruby
StepByStep::Rollout.deactivate_group(:comments, :admins)
```

#### Deactivating a single user feature

And there this one user who could see the comments. Let's hide them from him again:

```ruby
StepByStep::Rollout.deactivate_user(:comments, User.first)
```

#### Deactivating a feature for a fraction of users

Remember those 20% who could see your new feature? Let's get rid of them, too:

```ruby
StepByStep::Rollout.deactivate_percentage(:comments)
```

### Displaying features

StepByStep comes with a few helper methods, one of which is called `rollout?`. It's available in your controllers as well as in your views. You just pass it the feature name to check if it has been rolled out to your `current_user`.

#### View example

It's as simple as:

```erb
<% if rollout?(:comments) %>
  <%= # your awesome feature here %>
<% end %>
```

#### Controller example

Sometimes, you may want to hide a view completely. You can either do this directly in a controller action:

```ruby
def show
  unless rollout?(:comments)
    redirect_to root_path, notice: 'Access denied'
  end
end
```

or preferably using before actions:

```ruby
before_action :rollout

private
def rollout
  unless rollout?(:comments)
    redirect_to root_path, notice: 'Access denied'
  end
end
```

### Degrading a feature

Every rollout comes with a `failure_count`. A helper method is added to your application controller that allows you to track exceptions and increments the failure count for your feature. A failure count of 1 or higher disables your feature.

For instance, you could degrade a feature doing the following in your feature controller:

```ruby
around_filter :degrade

private
def degrade
  degrade_feature(:comments) { yield }
end
```

## Foolish assumptions

- You have a `current_user` method in your application controller that returns the authenticated user or nil if not authenticated (standard behavior, used e.g. by Devise)
- You are using Rails
- Your user model's primary key is `id` (Rails default)

## Dependencies

StepByStep requires Rails 3.2 or higher.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/step_by_step/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
