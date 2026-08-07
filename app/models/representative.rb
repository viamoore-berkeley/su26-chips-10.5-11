# frozen_string_literal: true

# == Schema Information
#
# Table name: representatives
#
#  id             :integer          not null, primary key
#  contact_form   :string
#  facebook       :string
#  name           :string
#  ocdid          :string
#  office_address :string
#  party          :string
#  phone          :string
#  photo_url      :string
#  title          :string
#  twitter        :string
#  website        :string
#  youtube        :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  bioguide_id    :string
#
class Representative < ApplicationRecord
  has_many :news_items, dependent: :delete_all

  PHOTO_URL_TEMPLATE = 'https://bioguide.congress.gov/bioguide/photo/%s/%s.jpg'

  # Review the Geocodio docs
  # https://www.geocod.io/docs/#congressional-districts
  def self.geocodio_search(query)
    geocodio_api_key = ENV.fetch('GEOCODIO_API_KEY', Rails.application.credentials[:GEOCODIO_API_KEY])
    raise ArgumentError, 'Missing GEOCODIO_API_KEY' if geocodio_api_key.blank?

    geocodio = Geocodio::Gem.new(geocodio_api_key)
    geocodio.geocode(query, ['cd'])
  end

  # Builds/updates a Representative for every legislator across all matching
  # districts, deduped so a member shared by multiple districts appears once.
  # See https://www.geocod.io/docs/#data-appends-fields
  def self.civic_api_to_representative_params(rep_info)
    response = rep_info['results'][0]['response']
    fields = response['results'][0]['fields']
    officials = find_matching_districts(fields).flat_map { |district| legislators_for(district) }
    officials.map { |o| find_rep(o, title: o['type'], ocdid: o.dig('references', 'govtrack_id')) }.uniq(&:id)
  end

  def self.find_matching_districts(fields)
    return [] unless fields.present? && fields['congressional_districts'].present?

    fields['congressional_districts']
  end

  def self.legislators_for(district)
    return [] unless district.present? && district['current_legislators'].present?

    district['current_legislators']
  end

  # Find an existing representative by ocdid (or build a new one) and populate it
  # from the Geocodio payload, so re-searching updates in place instead of
  # creating a duplicate.
  def self.find_rep(official, title: '', ocdid: '')
    rep = find_or_initialize_by(ocdid: ocdid)
    attrs = geocodio_attributes(official)
    attrs[:title] = title if title.present?
    rep.update!(attrs)
    rep
  end

  def self.photo_url_for(bioguide_id)
    return nil if bioguide_id.blank?

    format(PHOTO_URL_TEMPLATE, bioguide_id[0], bioguide_id)
  end

  def self.geocodio_attributes(official)
    bio = official['bio'] || {}
    contact = official['contact'] || {}
    social = official['social'] || {}
    refs = official['references'] || {}

    {
      name: "#{bio['first_name']} #{bio['last_name']}".strip,
      title: official['type'],
      ocdid: refs['govtrack_id'],
      party: bio['party'],
      bioguide_id: refs['bioguide_id'],
      photo_url: photo_url_for(refs['bioguide_id']),
      office_address: contact['address'],
      phone: contact['phone'],
      website: contact['url'],
      contact_form: contact['contact_form'],
      twitter: social['twitter'],
      facebook: social['facebook'],
      youtube: social['youtube']
    }
  end

  def update_from_geocodio(official)
    update!(self.class.geocodio_attributes(official))
    self
  end
end
