class CreateAuditLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :audit_logs do |t|
      t.references :user, null: true, foreign_key: { on_delete: :nullify }
      t.string :action, null: false
      t.string :resource_type, null: false
      t.bigint :resource_id, null: false
      t.jsonb :details, null: false, default: {}
      t.string :ip_address

      t.timestamps
    end

    add_index :audit_logs, :action
    add_index :audit_logs, :created_at
    add_index :audit_logs, [:resource_type, :resource_id]
  end
end
