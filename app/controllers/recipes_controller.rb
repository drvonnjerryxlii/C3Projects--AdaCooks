class RecipesController < ApplicationController
  before_action :set_recipe, only: [:ingredients, :add_ingredients,
    :add_ingredient, :remove_ingredient, :show, :edit, :update, :destroy]
  before_action :require_user_login, only: [:ingredients, :add_ingredients,
    :add_ingredient, :remove_ingredient, :new, :create, :edit, :update,
    :destroy]

  def index
    @recipes = Recipe.alphabetized
  end

  def show; end

  def new
    @recipe = Recipe.new
    @recipe.ingredients.build
  end

  def create
    @recipe = Recipe.new(create_params)

    if @recipe.save
      flash[:success] = "Mmmm, #{ @recipe.proper_name } sounds delicious."
      redirect_to user_recipe_ingredients_path(@authenticated_user, @recipe)
    else
      flash[:error] = @recipe.errors.full_messages.first
      render :new
    end
  end

  def edit; end

  def update
    if @recipe.update(edit_params)
      flash[:success] = "What a great way to improve #{ @recipe.proper_name }! You can update the ingredients now."
      redirect_to user_recipe_ingredients_path(@authenticated_user, @recipe)
    else
      flash[:error] = @recipe.errors.full_messages.first
      render :edit
    end
  end

  def destroy
    name = @recipe.proper_name
    associated_ingredients = @recipe.ingredients

    @recipe.destroy
    # forces each ingredient record to reload so that ingredient.recipe no longer
    # shows the association with the deleted recipe (SQL caches the old association)
    associated_ingredients.each { |ingredient| ingredient.reload }

    flash[:success] = "Your recipe has been destroyed. Goodbye, #{ name }!"
    redirect_to recipes_path
  end

  def ingredients
    @ingredients = Ingredient.alphabetized
  end

  def add_ingredients
    ingredient_ids = params[:ingredients]

    unless ingredient_ids.nil?
      ingredients = ingredient_ids.map { |id| Ingredient.find(id) }

      ingredients.each do |ingredient|
        @recipe.add_ingredient_association(ingredient) unless @recipe.ingredients.include? ingredient
      end

      flash[:success] = "HERE IT IS: Hi, new & improved #{ @recipe.proper_name }."
      redirect_to recipe_path(@recipe)
    else
      flash[:error] = "You must select at least one ingredient!"

      redirect_to user_recipe_ingredients_path(@authenticated_user, @recipe)
    end
  end

  def remove_ingredient
    ingredient_name = Ingredient.find(params[:id]).proper_name
    @recipe.remove_ingredient_association(params[:id])
    flash[:success] = "#{ ingredient_name } has been removed from #{ @recipe.proper_name }."

    redirect_to recipe_path(@recipe)
  end

  private
    def create_params
      recipe = edit_params
      recipe[:user_id] = session[:user_id]
      return recipe
    end

    def edit_params
      recipe = params.require(:recipe).permit(:name, :steps, :avatar, :description)
    end

    def set_recipe
      id = params[:recipe_id] || params[:id]
      @recipe = Recipe.find(id)
    end
end
