module StepByStep
  class Rollout < ActiveRecord::Base
    def match?(user)
      public? || user && enabled? && (match_group?(user) || match_user?(user) || match_percentage?(user))
    end

    def public?
      group == 'all'
    end

    # Activates a feature for everyone
    def self.activate(name)
      create! name: name, group: :all
    end

    # Activates a feature for a specific group
    def self.activate_group(name, group)
      create! name: name, group: group
    end

    # Activates a feature for a fraction of users
    def self.activate_percentage(name, percentage)
      create! name: name, percentage: percentage
    end

    # Activates a feature for a specific user
    def self.activate_user(name, user)
      create! name: name, user_id: user.id
    end

    # Deactivates a feature for everyone
    def self.deactivate(name)
      where(name: name).destroy_all
    end

    # Deactivates a feature for a specific group
    def self.deactivate_group(name, group)
      where(name: name, group: group).destroy_all
    end

    # Deactivates a feature for a specific user
    def self.deactivate_user(name, user)
      where(name: name, user_id: user.id).destroy_all
    end

    # Deactivates a feature for a fraction of users
    def self.deactivate_percentage(name)
      where('name = ? AND percentage IS NOT NULL', name).destroy_all
    end

    # Define groups
    def self.define_group(group, &block)
      @@groups ||= []
      @@groups << [group.to_sym, ->(user){ yield(user) }]
    end

    define_group(:all) do
      true
    end

  private
    def enabled?
      failure_count.to_i < 1
    end

    def match_group?(user)
      if group
        # Find the group whose block should be evaluated based on its name
        g = @@groups.select { |i| i.first.to_sym == group.to_sym }

        if g.present?
          # There could theoretically be multiple groups with the same name;
          # only take the last one
          g = g.last

          # g is now an array that looks like this:
          # [:group_name, code_block]
          # Call the code block here with the user
          g.last.call(user)
        end
      end
    end

    def match_user?(user)
      user_id ? user_id == user.id : false
    end

    def match_percentage?(user)
      percentage ? Zlib::crc32(user.id.to_s) % 100 < percentage : false
    end
  end
end
