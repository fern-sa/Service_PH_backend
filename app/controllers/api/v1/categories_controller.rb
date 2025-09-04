class Api::V1::CategoriesController < ApplicationController
  include ApiResponse
  include ErrorHandling
  include Serialization
  
  before_action :authenticate_user!, except: [:index, :show]
  before_action :find_category, only: [:show]

  def index
    categories = Category.active.ordered
    render_success(data: serialized_categories(categories))
  end

  def show
    render_success(data: serialized_category(@category))
  end

  private

  def find_category
    @category = Category.find(params[:id])
  end

end