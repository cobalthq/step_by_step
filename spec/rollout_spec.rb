require "spec_helper"

module StepByStep
  describe Rollout do
    let!(:user) { Struct.new(:id, :email) }

    # User who matches
    let!(:user_1) { user.new(1, 'test@test.com') }

    # User who doesn't match
    let!(:user_2) { user.new(2, 'nope@test.com') }

    # User who is not logged in (current user will return nil if nobody is logged in)
    let!(:user_3) { nil }

    before :all do
      Rollout.define_group(:admins) do |user|
        emails = [
          'test@test.com'
        ]
        emails.include?(user.email)
      end
    end

    it 'rolls out to the public' do
      rollout = Rollout.activate(:feature)
      expect(rollout.match?(user_3)).to be_truthy
    end

    it 'rolls out to all' do
      rollout = Rollout.activate(:feature)
      expect(rollout.match?(user_1)).to be_truthy
      expect(rollout.match?(user_2)).to be_truthy
    end

    it 'rolls out to a group' do
      rollout = Rollout.activate_group(:feature, :admins)
      expect(rollout.match?(user_1)).to be_truthy
      expect(rollout.match?(user_2)).to be_falsey
    end

    it 'rolls out to a user' do
      rollout = Rollout.activate_user(:feature, user_1)
      expect(rollout.match?(user_1)).to be_truthy
      expect(rollout.match?(user_2)).to be_falsey
    end

    it 'rolls out to a user while group is empty string instead of `nil`' do
      rollout = Rollout.create(user_id: user_1.id, group: '')
      expect(rollout.match?(user_1)).to be_truthy
      expect(rollout.match?(user_2)).to be_falsey
    end

    it 'rolls out to a percentage' do
      rollout = Rollout.activate_percentage(:feature, 50)

      expect(rollout.match?(user_1)).to be_falsey
      expect(rollout.match?(user_2)).to be_truthy
    end

    it 'handles users who are not logged in' do
      rollout = Rollout.activate_group(:feature, :admins)
      expect(rollout.match?(user_3)).to be_falsey
    end

    it 'deactivates all' do
      Rollout.activate_group(:feature, :all)
      Rollout.deactivate(:feature)
      expect(Rollout.where(name: :feature).any?).to be_falsey
    end

    it 'deactivates a group' do
      Rollout.activate_group(:feature, :admins)
      Rollout.deactivate_group(:feature, :admins)
      expect(Rollout.where(name: :feature, group: :admins).any?).to be_falsey
    end

    it 'deactivates a user' do
      Rollout.activate_user(:feature, user_1)
      Rollout.deactivate_user(:feature, user_1)
      expect(Rollout.where(name: :feature, user_id: user_1.id).any?).to be_falsey
    end

    it 'deactivates a percentage' do
      Rollout.activate_percentage(:feature, 50)
      Rollout.deactivate_percentage(:feature)
      expect(Rollout.where('name = ? AND percentage IS NOT NULL', :feature).any?).to be_falsey
    end
  end
end
