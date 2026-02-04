class Project < ApplicationRecord
  belongs_to :user
  has_many :recipes, dependent: :destroy
  has_many :ingredients, dependent: :destroy
  has_many :tags, dependent: :destroy

  def export_payload
    tags_scope = tags.order(:id)
    ingredients_scope = ingredients.includes(:tags).order(:id)
    recipes_scope = recipes.includes(
      :ingredient_recipes => :ingredient,
      :recipe_recipes => :recipe_item,
      :recipe_tags => :tag
    ).order(:id)

    {
      tags: tags_scope.map { |t|
        {
          name: t.name,
          description: t.description,
          image: t.export_image
        }
      },

      ingredients: ingredients_scope.map { |ing|
        {
          id: ing.id,
          name: ing.name,
          image: ing.export_image,
          description: ing.description,
          tags: ing.tags.order(:id).pluck(:name)
        }
      },

      recipes: recipes_scope.map { |r|
        {
          name: r.name,
          description: r.description,
          image: r.export_image,
          ingredients: export_recipe_ingredients(r),
          tags: export_recipe_tags(r)
        }
      }
    }
  end

  private

  def export_recipe_ingredients(recipe)
    items = []

    recipe.ingredient_recipes.each do |ir|
      items << {
        type: "ingredient",
        id: ir.ingredient_id,
        quantity: ir.quantity.to_i
      }
    end

    recipe.recipe_recipes.each do |rr|
      items << {
        type: "recipe",
        name: rr.recipe_item&.name,
        quantity: rr.quantity.to_i
      }
    end

    recipe.recipe_tags
          .where(tag_type: RecipeTag::TAG_TYPES[:as_ingredient])
          .each do |rt|
      items << {
        type: "tag",
        name: rt.tag&.name,
        quantity: rt.quantity.to_i
      }
    end

    items
  end

  def export_recipe_tags(recipe)
    recipe.recipe_tags
          .where(tag_type: RecipeTag::TAG_TYPES[:as_tag])
          .includes(:tag)
          .map { |rt| rt.tag&.name }
          .compact
          .uniq
  end
end
