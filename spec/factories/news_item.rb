# frozen_string_literal: true

FactoryBot.define do
  factory :news_item do
    id { 10 }
    link { 'news.com/this-is-a-test' }
    title { 'Test News Story' }
    representative_id { 987_654 }
    user
  end

  factory :news_item_with_rep, class: 'NewsItem' do
    id { 10 }
    link { 'news.com/this-is-a-test' }
    title { 'Test News Story' }
    representative
  end
end
