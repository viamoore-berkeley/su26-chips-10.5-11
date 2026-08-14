# frozen_string_literal: true

class MyNewsItemsController < ApplicationController
  before_action :require_login!

  before_action :set_representative, except: :new_search
  before_action :set_representatives_list
  before_action :set_news_item, only: %i[edit update destroy]

  def new
    @news_item = NewsItem.new(
      representative_id: params[:representative_id],
      issue: params[:issue]
    )
  end

  def new_search
    @representatives_list = Representative.all
    @issues = NewsItem.issues

    return unless params[:issue].present? && params[:representative_id].present?

    @representative = Representative.find(params[:representative_id])

    @search_issue = params[:issue]
  end

  def edit; end

  def create
    @news_item = NewsItem.new(news_item_params)
    @news_item.representative_id = @representative.id
    @news_item.user_id = current_user&.id

    if @news_item.save
      redirect_to representative_news_item_path(@representative, @news_item),
                  notice: 'News item was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @news_item.update(news_item_params)
      redirect_to representative_news_item_path(@representative, @news_item),
                  notice: 'News item was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @news_item.destroy
    redirect_to representative_news_items_path(@representative),
                notice: 'News was successfully destroyed.'
  end

  # Searches for the top 5
  def search
    @issue = params[:issue]
    if NewsItem.issues.include?(@issue)
      @top_five = NULL # needs to pull top five off of the NewsAPI and create the find_top_five
      render :search_results
    else
      render :search
    end
  end

  # Save an article chosen from the search results as a news item.
  def save
    @news_item = NewsItem.create_from_article(@representative, current_user, article_params)
    if @news_item.persisted?
      redirect_to representative_news_item_path(@representative, @news_item),
                  notice: 'Article saved.'
    else
      redirect_to representative_news_items_path(@representative),
                  alert: 'Could not save that article.'
    end
  end

  private

  def set_representative
    @representative = Representative.find(
      params[:representative_id]
    )
  end

  def set_representatives_list
    @representatives_list = Representative.all.map { |r| [r.name, r.id] }
  end

  def set_news_item
    @news_item = NewsItem.find(params[:id])
  end

  def news_item_params
    params.require(:news_item).permit(:title, :issue, :description, :link, :representative_id)
  end

  def article_params
    params.permit(:title, :link, :description, :issue)
  end
end
