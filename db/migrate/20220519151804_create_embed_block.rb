class CreateEmbedBlock < ActiveRecord::Migration[6.1]
  def change
    create_table :embed_blocks, id: :uuid do |t|
      t.string :title, null: false
      t.string :description
      t.string :token
      t.string :url
      t.datetime :start_time
      t.datetime :end_time
      t.references :meeting, foreign_key: { to_table: :meetings }, type: :uuid
      t.string :spotlighted_users, array: true, default: []
      t.string :stage_users, array: true, default: []
      

      t.timestamps
    end
  end
end
