class DropUnusedJoinTables < ActiveRecord::Migration[8.1]
  def change
    drop_table :ingredients_recipes, if_exists: true
    drop_table :ingredients_tags, if_exists: true
    drop_table :recipes_tags, if_exists: true
  end
end
