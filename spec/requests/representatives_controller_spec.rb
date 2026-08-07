# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RepresentativesController do
  before { host! '127.0.0.1' }

  let(:detailed_rep) do
    Representative.create!(name: 'Jane Doe', title: 'senator', party: 'Democrat',
                           office_address: '1234 Longworth, Washington DC', phone: '202-555-0100',
                           website: 'https://jane.house.gov', twitter: 'RepJaneDoe',
                           bioguide_id: 'D000197')
  end

  it 'renders full details for a populated representative' do
    get representative_path(detailed_rep)
    expect(response.body).to include('Jane Doe', 'Democrat', '202-555-0100')
  end

  it 'renders without error when fields are missing' do
    rep = Representative.create!(name: 'No Data Person')
    get representative_path(rep)
    expect(response).to have_http_status(:ok)
  end
end
