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
require 'rails_helper'

RSpec.describe NewsItem do
  before do
    news_attributes = {
      id:               7,
      link:             'https://xkcd.com/',
      title:            'Trick Play'
    }
    rep = Representative.create(id: 10)
    @test_news_item = rep.news_items.create!(news_attributes)
  end

  it 'can find news item' do
    expect(described_class.find_for(10)).to eq @test_news_item
  end

  it 'fails to find missing item' do
    expect(described_class.find_for(100)).to be_nil
  end
end
