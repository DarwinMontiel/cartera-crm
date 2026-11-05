class CreatePaymentAgreements < ActiveRecord::Migration[8.1]
  def change
    create_table :payment_agreements do |t|
      t.references :obligation, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: "active"
      t.decimal :total_amount, precision: 15, scale: 2, null: false
      t.string :reference, null: false
      t.text :notes
      t.timestamps
    end

    # Idempotencia: un sistema externo (p. ej. un bot RPA) puede reintentar con la misma referencia.
    add_index :payment_agreements, :reference, unique: true
    # Regla de negocio garantizada por la base: un solo acuerdo activo por obligación.
    add_index :payment_agreements, :obligation_id, unique: true, where: "status = 'active'",
      name: "index_payment_agreements_one_active_per_obligation"
    add_check_constraint :payment_agreements, "total_amount > 0", name: "agreements_total_positive"
    add_check_constraint :payment_agreements,
      "status IN ('active', 'fulfilled', 'broken', 'cancelled')", name: "agreements_status_check"

    create_table :installments do |t|
      t.references :payment_agreement, null: false, foreign_key: { on_delete: :cascade }
      t.integer :number, null: false
      t.date :due_on, null: false
      t.decimal :amount, precision: 15, scale: 2, null: false
      t.datetime :paid_at
      t.timestamps
    end

    add_index :installments, [ :payment_agreement_id, :number ], unique: true
    add_index :installments, :due_on
    add_check_constraint :installments, "amount > 0", name: "installments_amount_positive"
  end
end
