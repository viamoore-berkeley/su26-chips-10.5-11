# frozen_string_literal: true

require 'rails_helper'

describe NewsItemsController do
  before do
    @rep = create(:representative)
    @user = create(:user)
    @news = create(:news_item, representative: @rep, user: @user)
    @params = {
      representative_id: @rep.id,
      id: @news.id
    }
  end

  describe 'GET index' do
    it 'returns a successful response' do
      get :index, params: @params
      expect(response).to be_successful
    end
  end

  # TODO: add checks for results, not just 200 response
  describe 'GET show' do
    it 'returns a successful response' do
      get :show, params: @params
      expect(response).to be_successful
    end
  end

  describe ''
end
