# frozen_string_literal: true

require 'rails_helper'

describe RepresentativesController do
  before do
    @rep = create(:representative)
  end

  describe 'GET index' do
    it 'returns a successful response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns @representatives' do
      get :index
      expect(assigns(:representatives)).to eq(Representative.all)
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template('index')
    end
  end

  describe 'GET show' do
    it 'returns a successful response' do
      get :show, params: { id: @rep.id }
      expect(response).to be_successful
    end

    it 'assigns @representative' do
      get :show, params: { id: @rep.id }
      expect(assigns(:representative)).to eq(@rep)
    end

    it 'renders the show template' do
      get :show, params: { id: @rep.id }
      expect(response).to render_template('show')
    end
  end
end
