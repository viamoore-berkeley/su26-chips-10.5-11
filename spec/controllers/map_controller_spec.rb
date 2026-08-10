# frozen_string_literal: true

require 'rails_helper'

describe MapController do
  before do
    @california = create(:state)
    @washington = create(:washington)

    @alameda = create(:county, state: @california)
    @alpine  = create(:alpine_county, state: @california)
  end

  describe 'GET index' do
    it 'returns a successful response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns @states' do
      get :index
      expect(assigns(:states)).to eq(State.all)
    end

    it 'assigns @states_by_fips_code' do
      get :index
      expect(assigns(:states_by_fips_code)).to eq(State.all.index_by(&:std_fips_code))
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template('index')
    end
  end

  describe 'GET state' do
    it 'returns a successful response' do
      get :state, params: { use_route: '/state/', state_symbol: 'CA' }
      expect(response).to be_successful
    end

    it 'assigns @state' do
      get :state, params: { use_route: '/state/', state_symbol: 'CA' }
      expect(assigns(:state)).to eq(@california)
    end

    it 'assigns @county_details' do
      get :state, params: { use_route: '/state/', state_symbol: 'CA' }
      expect(assigns(:county_details)).to eq(@california.counties.index_by(&:std_fips_code))
    end

    it 'redirects to home page if invalid state' do
      get :state, params: { use_route: '/state/', state_symbol: 'XX' }
      expect(response).to redirect_to root_path
    end
  end

  describe 'GET county' do
    it 'returns a successful response' do
      get :county,
          params: { use_route: '/state/:state_symbol/county/:std_fips_code', state_symbol: 'CA',
std_fips_code: '001' }
      expect(response).to be_successful
    end

    it 'assigns @state' do
      get :county,
          params: { use_route: '/state/:state_symbol/county/:std_fips_code', state_symbol: 'CA',
std_fips_code: '001' }
      expect(assigns(:state)).to eq(@california)
    end

    it 'assigns @county' do
      get :county,
          params: { use_route: '/state/:state_symbol/county/:std_fips_code', state_symbol: 'CA',
std_fips_code: '001' }
      expect(assigns(:county)).to eq(@alameda)
    end

    it 'assigns @county_details' do
      get :county,
          params: { use_route: '/state/:state_symbol/county/:std_fips_code', state_symbol: 'CA',
std_fips_code: '001' }
      expect(assigns(:county_details)).to eq(@california.counties.index_by(&:std_fips_code))
    end

    it 'redirects to home page if invalid state' do
      get :county,
          params: { use_route: '/state/:state_symbol/county/:std_fips_code', state_symbol: 'XX',
std_fips_code: '001' }
      expect(response).to redirect_to root_path
    end
  end
end
