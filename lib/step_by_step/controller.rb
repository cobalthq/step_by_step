module StepByStep
  module Controller
    extend ActiveSupport::Concern

    included do
      helper_method :rollout?
      private_class_method :rollout?
      
      private_class_method :degrade_feature
    end

    def rollout?(name)
      Rollout.where(name: name).any? do |rollout|
        rollout.match?(current_user)
      end
    end

    def degrade_feature(name)
      yield
    rescue StandardError => e
      Rollout.where(name: name).each do |rollout|
        rollout.increment!(:failure_count)
      end
      raise e
    end
  end
end
