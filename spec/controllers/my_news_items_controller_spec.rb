# frozen_string_literal: true

require 'rails_helper'

describe MyNewsItemsController do
  before do
    @user = create(:user)
    @rep = create(:representative)
    @news_item = create(:news_item, representative: @rep)

    session[:user_id] = @user.id
  end

  describe 'GET new' do
    it 'returns success' do
      get :new, params: { representative_id: @rep.id }
      expect(response).to be_successful
    end
  end

  describe 'GET edit' do
    it 'returns success' do
      get :edit, params: { representative_id: @rep.id, id: @news_item.id }
      expect(response).to be_successful
    end
  end

  describe 'POST create' do
    it 'creates a news item' do
      expect { post_create }.to change(NewsItem, :count).by(1)
    end
  end

  def post_create
    post :create, params: {
      representative_id: @rep.id,
      news_item: valid_params
    }
  end

  def valid_params
    {
      title: 'New Title',
      description: 'Desc',
      link: 'https://example.com',
      representative_id: @rep.id
    }
  end

  describe 'PATCH update' do
    it 'updates the news item' do
      patch_update
      expect(@news_item.reload.title).to eq('Updated Title')
    end
  end

  def patch_update
    patch :update, params: {
      representative_id: @rep.id,
        id: @news_item.id,
        news_item: { title: 'Updated Title' }
    }
  end

  describe 'DELETE destroy' do
    it 'destroys the news item' do
      expect do
        delete :destroy, params: { representative_id: @rep.id, id: @news_item.id }
      end.to change(NewsItem, :count).by(-1)
    end
  end
end
