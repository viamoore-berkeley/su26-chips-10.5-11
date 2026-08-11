# frozen_string_literal: true

# == Schema Information
#
# Table name: news_items
#
#  id                :integer          not null, primary key
#  title             :string           not null
#  link              :string           not null
#  description       :text
#  representative_id :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  issue             :string
#
class NewsItem < ApplicationRecord
  # TODO: this belongs to a user (creator_id)
  belongs_to :representative

  def self.issues
    ['Free Speech', 'Immigration', 'Terrorism', 'Social Security and Medicare',
     'Abortion', 'Student Loans', 'Gun Control', 'Unemployment',
     'Climate Change', 'Homelessness', 'Racism', 'Tax Reform', 'Net Neutrality',
     'Religious Freedom', 'Border Security', 'Minimum Wage', 'Equal Pay']
  end

  def self.find_for(representative_id)
    NewsItem.find_by(
      representative_id: representative_id
    )
  end
end
