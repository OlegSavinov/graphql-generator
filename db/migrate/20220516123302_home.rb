class Home < ActiveRecord::Migration[6.1]
  def change
    create_table :homes, id: :uuid do |t|
      t.integer :number
      t.references :cilivilians, foreign_key: { to_table: :users }, type: :uuid, array: true, default: []
      t.integer :hight
      t.string :index
      

      t.timestamps
    end
  end
end
