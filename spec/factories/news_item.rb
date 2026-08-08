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

FactoryBot.define do
  factory :news_item do
    id { 10 }
    link { 'xkcd.com' }
    title { 'Test News Story' }
    representative_id { 987_654 }
  end
end
