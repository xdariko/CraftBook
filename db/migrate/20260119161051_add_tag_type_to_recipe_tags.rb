class AddTagTypeToRecipeTags < ActiveRecord::Migration[7.1]
  def change
    add_column :recipe_tags, :tag_type, :integer, default: 0, null: false
  end
end
