class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.references :board, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.integer :status, null: false, default: 0
      t.integer :votes_count, null: false, default: 0

      t.timestamps
    end
    add_index :posts, [ :board_id, :status ]
  end
end
