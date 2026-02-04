class Ingredient < ApplicationRecord
  has_many :ingredient_recipes, dependent: :destroy
  has_many :recipes, through: :ingredient_recipes
  has_many :ingredient_tags, dependent: :destroy
  has_many :tags, through: :ingredient_tags
  has_one_attached :image

  validates :name, presence: true
  
  def export_image
    image.attached? ? image.filename.to_s : nil
  end

  def image_url
    Rails.application.routes.url_helpers.rails_blob_url(image, only_path: true) if image.attached?
  end
end
