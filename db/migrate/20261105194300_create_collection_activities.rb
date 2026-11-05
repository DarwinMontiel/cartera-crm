class CreateCollectionActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :collection_activities do |t|
      t.references :obligation, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :channel, null: false
      t.string :outcome, null: false
      t.text :notes
      t.datetime :occurred_at, null: false
      t.date :promise_date
      t.decimal :promise_amount, precision: 15, scale: 2
      t.string :source, null: false, default: "web"
      t.timestamps
    end

    add_index :collection_activities, [ :obligation_id, :occurred_at ]
    add_index :collection_activities, :occurred_at
    add_check_constraint :collection_activities,
      "channel IN ('call', 'whatsapp', 'visit', 'email', 'sms')", name: "activities_channel_check"
    add_check_constraint :collection_activities,
      "outcome IN ('no_answer', 'voicemail', 'wrong_number', 'contact_holder', " \
      "'contact_third_party', 'refused', 'promise_to_pay')",
      name: "activities_outcome_check"
    add_check_constraint :collection_activities, "source IN ('web', 'api')", name: "activities_source_check"
    # Una promesa sin fecha o sin valor no se puede evaluar: se impide también a nivel de base.
    # Ojo con la lógica de tres valores: "NULL > 0" es NULL y un CHECK con NULL pasa; por eso
    # se exige explícitamente IS NOT NULL.
    add_check_constraint :collection_activities,
      "outcome <> 'promise_to_pay' OR " \
      "(promise_date IS NOT NULL AND promise_amount IS NOT NULL AND promise_amount > 0)",
      name: "activities_promise_complete"
  end
end
