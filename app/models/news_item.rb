# frozen_string_literal: true

# == Schema Information
#
# Table name: news_items
#
#  id                :integer          not null, primary key
#  description       :text
#  link              :string           not null
#  title             :string           not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  representative_id :integer          not null
#
# Indexes
#
#  index_news_items_on_representative_id  (representative_id)
#
class NewsItem < ApplicationRecord
  # TODO: this belongs to a user (creator_id)
  belongs_to :representative
  has_many :ratings, dependent: :destroy

  def self.find_for(representative_id)
    NewsItem.find_by(
      representative_id: representative_id
    )
  end

  def average_rating
    ratings.average(:value)&.to_f&.round(1)
  end

  def rate(user, value)
    rating = ratings.find_or_initialize_by(user: user)
    rating.value = value
    rating.save
    rating
  end
end
