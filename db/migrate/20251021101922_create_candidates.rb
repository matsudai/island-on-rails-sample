class CreateCandidates < ActiveRecord::Migration[8.1]
  def change
    create_table :candidates do |t|
      t.string :name
      t.string :solid_color
      t.string :faded_color
      t.integer :votes_count, default: 0, null: false

      t.timestamps
    end
  end
end
