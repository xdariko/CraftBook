class ProjectsController < ApplicationController
  before_action :set_user
  before_action :set_project, except: [ :index, :new, :create ]

  def index
    @projects = @user.projects
  end

  def new
    @project = Project.new
  end

  def edit
  end

  def delete
  end

  def create
    @project = Project.new(project_params)
    @project.user = @user

    respond_to do |format|
      if Project.exists?(name: project_params[:name])
        flash.now[:alert] = "Проект с таким именем уже существует."
        format.turbo_stream { render turbo_stream: turbo_stream.replace("project_form", partial: "projects/form", locals: { project: @project }) }
        format.html { redirect_to new_project_path, alert: "Проект с таким именем уже существует." }
      elsif @project.save
        format.turbo_stream do
          was_empty = @user.projects.count == 1

          streams = [
            turbo_stream.remove("empty_projects"),
            turbo_stream.append("projects",
              partial: "projects/project",
              locals: { project: @project }),
            turbo_stream.update("modalBox", { action: "remove" })
          ]

          if was_empty
            streams << turbo_stream.update("add_project_button",
              partial: "projects/add_project_button")
          end

          render turbo_stream: streams
        end
        format.html { redirect_to project_path(@project), notice: "Проект успешно создан." }
      else
        flash.now[:alert] = "Произошла ошибка при создании проекта."
        format.turbo_stream { render turbo_stream: turbo_stream.replace("project_form", partial: "projects/form", locals: { project: @project }) }
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @project.update(project_params)
        format.turbo_stream { render turbo_stream: turbo_stream.replace("project_#{@project.id}", partial: "projects/project", locals: { project: @project }) }
      else
        flash.now[:alert] = "Произошла ошибка при переименовании проекта."
        format.turbo_stream { render turbo_stream: turbo_stream.replace("project_form", partial: "projects/form", locals: { project: @project }) }
        format.html { render :edit }
      end
    end
  end

  def show
    @recipes = @project.recipes
    @ingredients = @project.ingredients
    @tags = @project.tags
  end

  def destroy
    @project.destroy
    respond_to do |format|
      format.turbo_stream do
        if @user.projects.empty?
          render turbo_stream: [
            turbo_stream.remove("project_#{@project.id}"),
            turbo_stream.update("empty_state_container",
              partial: "empty_state"),
            turbo_stream.update("add_project_button",
              html: ""),
            turbo_stream.update("modalBox", { action: "remove" })
          ]
        else
          render turbo_stream: [
            turbo_stream.remove("project_#{@project.id}"),
            turbo_stream.update("modalBox", { action: "remove" })
          ]
        end
      end
      format.html { redirect_to projects_path, notice: "Проект успешно удален." }
    end
  end

  def export
    payload = @project.export_payload

    respond_to do |format|
      format.html
      format.json do
        send_data(
          JSON.pretty_generate(payload),
          filename: "#{@project.name.parameterize}.json",
          type: "application/json; charset=utf-8"
        )
      end
    end
  end

  private

  def set_user
    @user = Current.user || User.find(session[:user_id])
  end

  def set_project
    @project = @user.projects.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name)
  end
end
