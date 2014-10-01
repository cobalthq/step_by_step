require "spec_helper"

module StepByStep
  describe ApplicationController do
    it { should respond_to :rollout? }
    it { should respond_to :degrade_feature }
  end
end
