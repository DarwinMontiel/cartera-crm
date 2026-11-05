class AddProfileToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :name, :string, null: false, default: ""
    add_column :users, :role, :string, null: false, default: "agent"
    add_check_constraint :users, "role IN ('admin', 'agent')", name: "users_role_check"
  end
end
