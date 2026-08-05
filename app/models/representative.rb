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

  # NOTE: This info only grabs data for the most likely represenative district
  # given a search. It would be good to adapt this to show all possible
  # matching representatives for a search / county.
  # See https://www.geocod.io/docs/#data-appends-fields
  def self.civic_api_to_representative_params(rep_info)
    response = rep_info['results'][0]['response']
    fields = response['results'][0]['fields']
    legislators = fields['congressional_districts'][0]['current_legislators']
    legislators.map { |official| find_rep(official) }
  end

  # Find an existing representative by bioguide_id (or build a new one), then
  # populate it from the Geocodio payload. Re-searching a district updates the
  # existing record instead of creating a duplicate. bioguide_id lives in the
  # references block and is unique per member; fall back to a new record when it
  # is missing so distinct officials never collapse onto one row.
  def self.find_rep(official)
    bioguide = official.dig('references', 'bioguide_id')
    rep = bioguide.present? ? find_or_initialize_by(bioguide_id: bioguide) : new
    rep.update_from_geocodio(official)
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
