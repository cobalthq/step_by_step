module StepByStep
  class ApplicationController < ActionController::Base
    def rollout?(name)
      Rollout.where(name: name).any? do |rollout|
        rollout.match?(current_user)
      end
    end
    helper_method :rollout?
    hide_action :rollout?

    def degrade_feature(name)
      yield
    rescue StandardError => e
      Rollout.where(name: name).each do |rollout|
        rollout.increment!(:failure_count)
      end
      raise e
    end
    hide_action :degrade_feature
  end
end
