# app/models/recipe_tag.rb
class RecipeTag < ApplicationRecord
  belongs_to :recipe
  belongs_to :tag

  TAG_TYPES = {
    as_tag: 0,
    as_ingredient: 1
  }.freeze

  validates :quantity,
    presence: true,
    numericality: { greater_than: 0 },
    if: -> { tag_type == TAG_TYPES[:as_ingredient] }

  def as_tag?
    tag_type == TAG_TYPES[:as_tag]
  end

  def as_ingredient?
    tag_type == TAG_TYPES[:as_ingredient]
  end

  after_initialize do
    self.tag_type ||= TAG_TYPES[:as_tag]
  end
end
