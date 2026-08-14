# frozen_string_literal: true

class NewsItemsController < ApplicationController
  before_action :set_representative
  before_action :set_news_item, only: %i[show rate]

  def index
    @news_items = @representative.news_items
    @curr_user_id = current_user&.id
  end

  def show; end

  def rate
    if current_user
      @news_item.rate(current_user, params[:value])
      flash[:notice] = 'Rating saved.'
    else
      flash[:alert] = 'Please log in to rate articles.'
    end
    redirect_to representative_news_item_path(@representative, @news_item), status: :see_other
  end

  private

  def set_representative
    @representative = Representative.find(
      params[:representative_id]
    )
  end

  def set_news_item
    @news_item = NewsItem.find(params[:id])
  end
end
