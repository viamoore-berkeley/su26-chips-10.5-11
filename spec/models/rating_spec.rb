# frozen_string_literal: true

# == Schema Information
#
# Table name: ratings
#
#  id           :integer          not null, primary key
#  value        :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  news_item_id :integer          not null
#  user_id      :integer          not null
#
# Indexes
#
#  index_ratings_on_news_item_id              (news_item_id)
#  index_ratings_on_user_id                   (user_id)
#  index_ratings_on_user_id_and_news_item_id  (user_id,news_item_id) UNIQUE
#
# Foreign Keys
#
#  news_item_id  (news_item_id => news_items.id)
#  user_id       (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Rating do
  let(:user) { create(:user) }
  let(:representative) { create(:representative) }
  let(:news_item) { create(:news_item, representative: representative, user: user) }

  it 'is valid with a value between 1 and 5' do
    expect(described_class.new(user: user, news_item: news_item, value: 3)).to be_valid
  end

  it 'is invalid with a value outside 1 to 5' do
    expect(described_class.new(user: user, news_item: news_item, value: 6)).not_to be_valid
  end

  it 'allows only one rating per user per article' do
    described_class.create!(user: user, news_item: news_item, value: 3)
    expect(described_class.new(user: user, news_item: news_item, value: 4)).not_to be_valid
  end

  it 'updates in place instead of duplicating when a user re-rates' do
    news_item.rate(user, 4)
    news_item.rate(user, 2)
    expect(news_item.ratings.count).to eq(1)
  end

  it 'averages ratings across users' do
    news_item.rate(user, 4)
    news_item.rate(create(:user, uid: 'user-2'), 2)
    expect(news_item.average_rating).to eq(3.0)
  end
end
