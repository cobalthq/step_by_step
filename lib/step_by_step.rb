require 'active_record'
require 'rails'
require 'step_by_step/version'
require 'step_by_step/rollout'
require 'step_by_step/controller'

module StepByStep
  class Engine < ::Rails::Engine
    initializer 'step_by_step.controllers' do |app|
      ActionController::Base.send :include, StepByStep::Controller
    end
  end
end
