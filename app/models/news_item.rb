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
  
  #Lists of issues
  def self.issues
    ["Free Speech", "Immigration", "Terrorism", "Social Security and Medicare", "Abortion", "Student Loans", "Gun Control", "Unemployment", "Climate Change", "Homelessness", "Racism", "Tax Reform", "Net Neutrality", "Religious Freedom", "Border Security", "Minimum Wage", "Equal Pay"]
  end
validate def val_issue
  if issue.blank?
    return
  end
  if !NewsItem.issues.include(issue)
    errors.add(:issue, 'Not a valid Issue!')
  end

  def self.find_for(representative_id)
    NewsItem.find_by(
      representative_id: representative_id
    )
  end
end
