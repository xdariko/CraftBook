class RecipesController < ApplicationController
  before_action :set_project
  before_action :set_recipe, except: [ :new, :create, :index ]

  def index
    @recipes = @project.recipes
  end

  def show
  end

  def new
    @recipe = @project.recipes.new
  end

  def create
    @recipe = @project.recipes.new(recipe_params)
    respond_to do |format|
      if @recipe.save
        format.turbo_stream { render turbo_stream: turbo_stream.action(:redirect, project_recipe_path(@project, @recipe)) }
        format.html { redirect_to project_recipe_path(@project, @recipe), notice: "Рецепт успешно создан." }
      else
        flash.now[:alert] = "Произошла ошибка при создании рецепта."
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @recipe.update(recipe_params)
        format.turbo_stream { render turbo_stream: turbo_stream.replace("info_recipe", partial: "recipes/info_recipe", locals: { recipe: @recipe }) }
        format.html { redirect_to project_recipe_path(@project, @recipe), notice: "Рецепт успешно изменен" }
      else
        flash.now[:alert] = "Произошла ошибка при изменении рецепта."
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def add_ingredient
    if params[:item_id].present? && params[:item_type].present?
      item_id = params[:item_id]
      item_type = params[:item_type]
      quantity = params[:quantity].present? ? params[:quantity].to_i : 1
      quantity = [ quantity, 1 ].max

      if item_type == "Ingredient"
        existing_record = @recipe.ingredient_recipes.find_by(ingredient_id: item_id)

        if existing_record
          existing_record.update(quantity: quantity)
          @item_recipe = existing_record
          respond_to do |format|
            format.turbo_stream {
              render turbo_stream: turbo_stream.replace(
                "ingredient_#{@item_recipe.ingredient.id}",
                partial: "recipes/item_card",
                locals: {
                  item_recipe: @item_recipe,
                  project: @project,
                  recipe: @recipe
                }
              )
            }
            format.html { redirect_to project_recipe_path(@project, @recipe), notice: "Количество обновлено" }
          end
        else
          @item_recipe = @recipe.ingredient_recipes.create(ingredient_id: item_id, quantity: quantity)

          if @item_recipe.persisted?
            respond_to do |format|
              format.turbo_stream {
                render turbo_stream: turbo_stream.append(
                  "items_list",
                  partial: "recipes/item_card",
                  locals: {
                    item_recipe: @item_recipe,
                    project: @project,
                    recipe: @recipe
                  }
                )
              }
              format.html { redirect_to project_recipe_path(@project, @recipe), notice: "Ингредиент успешно добавлен" }
            end
          else
            respond_to do |format|
              format.turbo_stream { head :unprocessable_entity }
              format.html { redirect_to project_recipe_path(@project, @recipe), alert: "Ошибка создания ингредиента" }
            end
          end
        end

      elsif item_type == "Recipe"
        existing_record = @recipe.recipe_recipes.find_by(recipe_item_id: item_id)

        if existing_record
          existing_record.update(quantity: quantity)
          @item_recipe = existing_record
          respond_to do |format|
            format.turbo_stream {
              render turbo_stream: turbo_stream.replace(
                "recipe_#{@item_recipe.recipe_item.id}",
                partial: "recipes/item_card",
                locals: {
                  item_recipe: @item_recipe,
                  project: @project,
                  recipe: @recipe
                }
              )
            }
            format.html { redirect_to project_recipe_path(@project, @recipe), notice: "Количество обновлено" }
          end
        else
          @item_recipe = @recipe.recipe_recipes.create(recipe_item_id: item_id, quantity: quantity)

          if @item_recipe.persisted?
            respond_to do |format|
              format.turbo_stream {
                render turbo_stream: turbo_stream.append(
                  "items_list",
                  partial: "recipes/item_card",
                  locals: {
                    item_recipe: @item_recipe,
                    project: @project,
                    recipe: @recipe
                  }
                )
              }
              format.html { redirect_to project_recipe_path(@project, @recipe), notice: "Рецепт успешно добавлен" }
            end
          else
            respond_to do |format|
              format.turbo_stream { head :unprocessable_entity }
              format.html { redirect_to project_recipe_path(@project, @recipe), alert: "Ошибка создания рецепта" }
            end
          end
        end

      elsif item_type == "Tag"
        existing_record = @recipe.recipe_tags.find_by(
          tag_id: item_id,
          tag_type: RecipeTag::TAG_TYPES[:as_ingredient]
        )

        if existing_record
          existing_record.update(quantity: quantity)
          @item_recipe = existing_record
          respond_to do |format|
            format.turbo_stream {
              render turbo_stream: turbo_stream.replace(
                "ingredient_tag_#{@item_recipe.id}",
                partial: "recipes/item_card",
                locals: {
                  item_recipe: @item_recipe,
                  project: @project,
                  recipe: @recipe
                }
              )
            }
            format.html { redirect_to project_recipe_path(@project, @recipe), notice: "Количество обновлено" }
          end
        else
          @item_recipe = @recipe.recipe_tags.create(
            tag_id: item_id,
            quantity: quantity,
            tag_type: RecipeTag::TAG_TYPES[:as_ingredient]
          )

          if @item_recipe.persisted?
            respond_to do |format|
              format.turbo_stream {
                render turbo_stream: turbo_stream.append(
                  "items_list",
                  partial: "recipes/item_card",
                  locals: {
                    item_recipe: @item_recipe,
                    project: @project,
                    recipe: @recipe
                  }
                )
              }
              format.html { redirect_to project_recipe_path(@project, @recipe), notice: "Тег добавлен как ингредиент" }
            end
          else
            respond_to do |format|
              format.turbo_stream { head :unprocessable_entity }
              format.html { redirect_to project_recipe_path(@project, @recipe), alert: "Ошибка создания тега" }
            end
          end
        end
      end

    else
      respond_to do |format|
        format.turbo_stream {
          flash.now[:alert] = "Пожалуйста, выберите элемент."
          render turbo_stream: turbo_stream.update("flash-container", partial: "shared/flash")
        }
        format.html {
          flash[:alert] = "Пожалуйста, выберите элемент."
          redirect_to project_recipe_path(@project, @recipe)
        }
      end
    end
  end

  def add_ingredient_modal
    used_ingredient_ids = @recipe.ingredient_recipes.pluck(:ingredient_id)
    used_recipe_ids = @recipe.recipe_recipes.pluck(:recipe_item_id)
    used_tag_ids = @recipe.recipe_tags.where(tag_type: RecipeTag::TAG_TYPES[:as_ingredient]).pluck(:tag_id)

    @available_ingredients = @project.ingredients.where.not(id: used_ingredient_ids)
    @available_recipes = @project.recipes.where.not(id: [ @recipe.id ] + used_recipe_ids)
    @available_tags = @project.tags.where.not(id: used_tag_ids)

    respond_to do |format|
      format.turbo_stream
      format.html { render partial: "recipes/add_ingredient_modal", layout: false }
    end
  end

  def add_tag_modal
    used_tag_ids = @recipe.recipe_tags.where(tag_type: RecipeTag::TAG_TYPES[:as_tag]).pluck(:tag_id)
    @available_tags = @project.tags.where.not(id: used_tag_ids)

    respond_to do |format|
      format.turbo_stream
      format.html { render partial: "recipes/add_tag_modal", layout: false }
    end
  end

  def add_tag
    if params[:tag_id].present?
      tag_id = params[:tag_id]

      existing_record = @recipe.recipe_tags.find_by(tag_id: tag_id, tag_type: RecipeTag::TAG_TYPES[:as_tag])

      if existing_record
        respond_to do |format|
          format.turbo_stream { head :ok }
          format.html { redirect_to project_recipe_path(@project, @recipe), notice: "Тег уже добавлен." }
        end
      else
        @recipe_tag = @recipe.recipe_tags.create(
          tag_id: tag_id,
          quantity: 1,
          tag_type: RecipeTag::TAG_TYPES[:as_tag]
        )

        if @recipe_tag.persisted?
          respond_to do |format|
            format.turbo_stream {
              render turbo_stream: turbo_stream.append(
                "tags_list",
                partial: "recipes/tag_card",
                locals: {
                  tag: @recipe_tag.tag,
                  recipe_tag: @recipe_tag,
                  project: @project,
                  recipe: @recipe
                }
              )
            }
            format.html { redirect_to project_recipe_path(@project, @recipe), notice: "Тег успешно добавлен" }
          end
        else
          respond_to do |format|
            format.turbo_stream { head :unprocessable_entity }
            format.html { redirect_to project_recipe_path(@project, @recipe), alert: "Ошибка создания тега" }
          end
        end
      end
    else
      respond_to do |format|
        format.turbo_stream { head :bad_request }
        format.html { redirect_to project_recipe_path(@project, @recipe), alert: "Пожалуйста, выберите тег." }
      end
    end
  end

  def remove_ingredient
    @item_recipe = nil

    if params[:ingredient_recipe_id].present?
      @item_recipe = IngredientRecipe.find_by(id: params[:ingredient_recipe_id])
    elsif params[:recipe_recipe_id].present?
      @item_recipe = RecipeRecipe.find_by(id: params[:recipe_recipe_id])
    elsif params[:recipe_tag_id].present?
      @item_recipe = RecipeTag.find_by(id: params[:recipe_tag_id])
    end

    if @item_recipe
      target =
        if @item_recipe.is_a?(RecipeTag)
          "ingredient_tag_#{@item_recipe.id}"
        elsif @item_recipe.is_a?(IngredientRecipe)
          "ingredient_#{@item_recipe.ingredient_id}"
        else
          "recipe_#{@item_recipe.recipe_item_id}"
        end

      @item_recipe.destroy

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.remove(target)
        end
        format.html do
          redirect_to project_recipe_path(@project, @recipe),
                      notice: "#{@item_recipe.class.model_name.human} удален"
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = "Не удалось найти запись."
          render turbo_stream: turbo_stream.update("flash-container", partial: "shared/flash")
        end
        format.html do
          flash[:alert] = "Не удалось найти запись."
          redirect_to project_recipe_path(@project, @recipe)
        end
      end
    end
  end

  def remove_tag
    @recipe_tag = RecipeTag.find_by(id: params[:recipe_tag_id])

    if @recipe_tag
      dom_id = "recipe_tag_#{@recipe_tag.id}"
      @recipe_tag.destroy

      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.remove(dom_id)
        end
        format.html do
          redirect_to project_recipe_path(@project, @recipe), notice: "Тег удален"
        end
      end
    else
      respond_to do |format|
        format.turbo_stream { head :ok }
        format.html do
          flash[:alert] = "Не удалось найти тег."
          redirect_to project_recipe_path(@project, @recipe)
        end
      end
    end
  end

  def delete
  end

  def destroy
    @recipe.destroy
    respond_to do |format|
      format.turbo_stream {
        render turbo_stream: turbo_stream.remove("recipe_#{@recipe.id}")
      }
      format.html { redirect_to project_path(@project), notice: "Рецепт успешно удален." }
    end
  end

  def export
    @project = Project.includes(recipes: [ :tags, ingredient_recipes: :ingredient ], ingredients: :tags).find(params[:id])
    render json: project_as_json(@project)
  end

  private
  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_recipe
    @recipe = @project.recipes.find(params[:id])
  end

  def recipe_params
    params.require(:recipe).permit(
      :name, :description, :image,
      ingredient_recipes_attributes: [ :id, :ingredient_id, :quantity, :_destroy ]
    )
  end
end
