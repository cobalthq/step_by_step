# StepByStep

This gem is largely inspired by the [Railscast on rollouts and degrading](http://railscasts.com/episodes/315-rollout-and-degrade), and also the [Rollout gem](https://github.com/FetLife/rollout) that is covered in aforementioned Railscast. While very comprehensive, it uses a Redis backend, that might not be desirable to everyone. Though there are some alternatives out there, most of them are either outdated or not as comprehensive as the rollout gem itself.

StepByStep instead uses ActiveRecord as backend and tries to cover as many use cases and features as the original rollout gem. It is easy to use since no additional backend needs to be set up, and adds some helpful methods that shall assist you in rolling out and degrading features reliably.

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

Let's say you have this new commenting feature that you would like to deploy to production, but you only want a subset of users to be able to see it.

### Rolling out to a group of users

You can define groups with any custom logic like this:

```ruby
StepByStep::Rollout.define_group :admins do |user|
  user.admin?
end
```

Roll out your feature to your group:

```ruby
StepByStep::Rollout.activate_group(:comments, :admins)
```

### Rolling out to everyone

```ruby
StepByStep::Rollout.activate(:comments)




```ruby
# Activates a feature for everyone
def StepByStep::Rollout.activate(name)
  create! name: name, group: :all
end

# Activates a feature for a fraction of users
def StepByStep::Rollout.activate_percentage(name, percentage)
  create! name: name, percentage: percentage
end

# Activates a feature for a specific user
def StepByStep::Rollout.activate_user(name, user)
  create! name: name, user_id: user.id
end

# Deactivates a feature for everyone
def StepByStep::Rollout.deactivate(name)
  where(name: name).destroy_all
end

# Deactivates a feature for a specific group
def StepByStep::Rollout.deactivate_group(name, group)
  where(name: name, group: group).destroy_all
end

# Deactivates a feature for a specific user
def StepByStep::Rollout.deactivate_user(name, user)
  where(name: name, user_id: user.id).destroy_all
end

# Deactivates a feature for a fraction of users
def StepByStep::Rollout.deactivate_percentage(name)
  where('name = ? AND percentage IS NOT NULL', name).destroy_all
end

# Define groups
def StepByStep::Rollout.define_group(group, &block)
  @@groups ||= []
  @@groups << [group.to_sym, ->(user){ yield(user) }]
end

```

## Dependencies

StepByStep requires Rails 3.2 or higher.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/step_by_step/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
