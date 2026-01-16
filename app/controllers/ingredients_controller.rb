class IngredientsController < ApplicationController
  before_action :set_project
  before_action :set_ingredient, except: [ :new, :create ]

  def index
    @ingredients = @project.ingredients
  end

  def new
    @ingredient = @project.ingredients.new
  end

  def create
    @ingredient = @project.ingredients.new(ingredient_params)
    respond_to do |format|
      if @ingredient.save
        format.turbo_stream { render turbo_stream: turbo_stream.action(:redirect, project_ingredient_path(@project, @ingredient)) }
        format.html { redirect_to project_ingredient_path(@project, @ingredient), notice: "Ингредиент успешно добавлен." }
      else
        flash.now[:alert] = "Произошла ошибка при добавлении ингредиента."
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @ingredient.update(ingredient_params)
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            "info_ingredient",
            partial: "ingredients/info_ingredient",
            locals: { ingredient: @ingredient }
          )
        }
        format.html { redirect_to project_ingredient_path(@project, @ingredient), notice: "Ингредиент успешно изменен" }
      else
        flash.now[:alert] = "Произошла ошибка при изменении ингредиента."
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def show
  end

  def add_tag
    if params[:tag_id].present?
      tag_id = params[:tag_id]

      existing_record = @ingredient.ingredient_tags.find_by(tag_id: tag_id)
      if existing_record
        respond_to do |format|
          format.turbo_stream { render turbo_stream: turbo_stream.update("tags_list", html: "") }
          format.html { redirect_to project_ingredient_path(@project, @ingredient) }
        end
      else
        @ingredient_tag = @ingredient.ingredient_tags.create(tag_id: tag_id)
        respond_to do |format|
          format.turbo_stream {
            render turbo_stream: turbo_stream.append(
              "tags_list",
              partial: "ingredients/tag_card",
              locals: { tag: @ingredient_tag.tag, ingredient_tag: @ingredient_tag }
            )
          }
          format.html { redirect_to project_ingredient_path(@project, @ingredient) }
        end
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.update("tags_list", html: "") }
        format.html { redirect_to project_ingredient_path(@project, @ingredient) }
      end
    end
  end

  def add_tag_modal
    @available_tags = @project.tags.where.not(id: @ingredient.tags.select(:id))

    respond_to do |format|
      format.turbo_stream
      format.html { render partial: "ingredients/add_tag_modal", layout: false }
    end
  end

  def remove_tag
    @ingredient_tag = IngredientTag.find(params[:ingredient_tag_id])
    @ingredient_tag.destroy

    respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.remove("ingredient_tag_#{@ingredient_tag.id}")
        }
        format.html { redirect_to project_ingredient_path(@project, @ingredient) }
    end
  end

  def delete
  end

  def destroy
    @ingredient.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.action(:redirect, project_path(@project)) }
      format.html { redirect_to project_path(@project), notice: "Ингредиент успешно удален." }
    end
  end

  private
    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_ingredient
      @ingredient = @project.ingredients.find(params[:id])
    end

    def ingredient_params
      params.require(:ingredient).permit(:name, :description, :image)
    end
end
