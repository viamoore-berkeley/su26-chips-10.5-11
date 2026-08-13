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
class NewsItem < ApplicationRecord
  belongs_to :user
  belongs_to :representative

  def self.issues
    ['Free Speech', 'Immigration', 'Terrorism', 'Social Security and Medicare',
     'Abortion', 'Student Loans', 'Gun Control', 'Unemployment',
     'Climate Change', 'Homelessness', 'Racism', 'Tax Reform', 'Net Neutrality',
     'Religious Freedom', 'Border Security', 'Minimum Wage', 'Equal Pay']
  end

  def self.find_for(representative_id)
    NewsItem.find_by(
      representative_id: representative_id,
      user_id: user_id
    )
  end

  def self.currents_search(query)
    currents_api_key = ENV.fetch('CURRENTS_API_KEY', Rails.application.credentials[:CURRENTS_API_KEY])
    raise ArgumentError, 'Missing CURRENTS_API_KEY' if currents_api_key.blank?

    response = Faraday.get(
      'https://api.currentsapi.services/v1/search',
      {
        keywords: query,
        language: 'en',
        page_size: 5
      },
      {
        'Authorization' => "Bearer #{currents_api_key}"
      }
    )
    JSON.parse(response.body)
  end
end
