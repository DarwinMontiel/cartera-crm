class CreateClients < ActiveRecord::Migration[8.1]
  def change
    enable_extension "pg_trgm"

    create_table :clients do |t|
      t.string :document_number, null: false
      t.string :full_name, null: false
      t.string :email
      t.string :phone
      t.string :city, null: false
      t.string :segment, null: false, default: "masivo"
      t.timestamps
    end

    add_index :clients, :document_number, unique: true
    # Búsqueda por nombre con ILIKE '%texto%' usando trigramas (evita full scan).
    add_index :clients, :full_name, using: :gin, opclass: :gin_trgm_ops
    add_check_constraint :clients, "segment IN ('masivo', 'preferente', 'pyme')", name: "clients_segment_check"
    add_check_constraint :clients, "document_number ~ '^[0-9]{6,10}$'", name: "clients_document_number_format"
  end
end
