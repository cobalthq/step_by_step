ActiveRecord::Schema.define do
  self.verbose = false

  create_table :rollouts, force: true do |t|
    t.string :name
    t.string :group
    t.integer :user_id
    t.integer :percentage
    t.integer :failure_count

    t.timestamps null: false
  end
end
