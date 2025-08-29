class Api::V1::CategoriesController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :find_category, only: [:show]

  def index
    categories = Category.active.ordered
    render json: {
      status: { code: 200 },
      data: categories.map { |category| CategorySerializer.new(category).serializable_hash[:data][:attributes] }
    }
  end

  def show
    render json: {
      status: { code: 200 },
      data: CategorySerializer.new(@category).serializable_hash[:data][:attributes]
    }
  end

  private

  def find_category
    @category = Category.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Category not found' }, status: :not_found
  end
end