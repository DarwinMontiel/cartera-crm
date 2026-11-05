class CreateObligations < ActiveRecord::Migration[8.1]
  def change
    create_table :obligations do |t|
      t.references :client, null: false, foreign_key: true
      t.string :number, null: false
      t.string :product, null: false
      t.decimal :principal_balance, precision: 15, scale: 2, null: false
      t.integer :days_past_due, null: false, default: 0
      t.string :status, null: false, default: "current"
      t.date :disbursed_on, null: false
      t.timestamps
    end

    add_index :obligations, :number, unique: true
    add_index :obligations, [ :status, :days_past_due ]
    add_check_constraint :obligations, "principal_balance >= 0", name: "obligations_balance_non_negative"
    add_check_constraint :obligations, "days_past_due >= 0", name: "obligations_days_past_due_non_negative"
    add_check_constraint :obligations,
      "status IN ('current', 'delinquent', 'in_agreement', 'paid_off', 'charged_off')",
      name: "obligations_status_check"
    add_check_constraint :obligations,
      "product IN ('credit_card', 'personal_loan', 'microcredit', 'vehicle')",
      name: "obligations_product_check"
  end
end
