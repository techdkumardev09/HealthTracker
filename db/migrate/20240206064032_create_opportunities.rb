class CreateOpportunities < ActiveRecord::Migration[7.0]
  def change
    create_table :opportunities do |t|
      t.text :procedure_name
      t.references :patient, foreign_key: { to_table: :members }
      t.references :doctor, foreign_key: { to_table: :members }
      t.jsonb :stage_history, default: []

      t.timestamps
    end
  end
end
