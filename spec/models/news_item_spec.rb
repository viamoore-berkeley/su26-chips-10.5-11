# frozen_string_literal: true

# == Schema Information
#
# Table name: news_items
#
#  id                :integer          not null, primary key
#  description       :text
#  issue             :string
#  link              :string           not null
#  title             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  representative_id :integer          not null
#  user_id           :integer          not null
#
# Indexes
#
#  index_news_items_on_representative_id  (representative_id)
#  index_news_items_on_user_id            (user_id)
#
# Foreign Keys
#
#  user_id  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe NewsItem do
  before do
    Representative.create(id: 10)
    User.create(uid: '0', provider: 1)
  end

  describe 'currents_search (network stubbed)' do
    let(:currents_body) { Rails.root.join('spec/fixtures/currents_response.json').read }

    before do
      ENV['CURRENTS_API_KEY'] = 'fake-key'
      stub_request(:get, 'https://api.currentsapi.services/v1/search').with(
        query: {
          keywords: 'Immigration',
          language: 'en',
          page_size: '5'
        },
        headers: {
          'Authorization' => 'Bearer fake-key'
        }
      ).to_return(
        status: 200,
        body: currents_body,
        headers: { 'Content-Type' => 'application/json' }
      )
    end

    it 'fetches and parses representatives without hitting the network' do
      result = described_class.currents_search('Immigration')
      expect(result['news'].first['title']).to eq('Test Article')
    end
  end
end
