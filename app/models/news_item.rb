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
#
# Indexes
#
#  index_news_items_on_representative_id  (representative_id)
#
class NewsItem < ApplicationRecord
  # TODO: this belongs to a user (creator_id)
  belongs_to :representative
  has_many :ratings, dependent: :destroy

  # Lists of issues
  def self.issues
    ['Free Speech', 'Immigration', 'Terrorism', 'Social Security and Medicare', 'Abortion', 'Student Loans',
     'Gun Control', 'Unemployment', 'Climate Change', 'Homelessness', 'Racism', 'Tax Reform', 'Net Neutrality',
     'Religious Freedom', 'Border Security', 'Minimum Wage', 'Equal Pay']
  end
  # fixing git`
  validate def val_issue
    return if issue.blank?

    return if NewsItem.issues.include?(issue)

    errors.add(:issue, 'Not a valid Issue!')
  end

  def self.find_for(representative_id)
    NewsItem.find_by(
      representative_id: representative_id
    )
  end

  # Save an article chosen from a news search as a news item for the given
  # representative, deduped by link so the same article isn't saved twice.
  def self.create_from_article(representative, article)
    representative.news_items.find_or_create_by(link: article[:link]) do |item|
      item.title = article[:title]
      item.description = article[:description]
      item.issue = article[:issue]
    end
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
