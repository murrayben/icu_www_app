class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :title
      t.string :subtitle
      t.text :content
      t.string :content_type
      t.integer :changed_by_id
      t.string :authorized_by
      t.text :reason_changed
      t.boolean :is_current
      t.integer :previous_version_id

      t.timestamps null: false
    end
    add_foreign_key :documents, :users, column: :changed_by_id
    add_foreign_key :documents, :documents, column: :previous_version_id
  end
end
