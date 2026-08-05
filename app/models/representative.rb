# frozen_string_literal: true

# == Schema Information
#
# Table name: representatives
#
#  id         :integer          not null, primary key
#  name       :string
#  ocdid      :string
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Representative < ApplicationRecord
  has_many :news_items, dependent: :delete_all

  # Review the Geocodio docs
  # https://www.geocod.io/docs/#congressional-districts
  def self.geocodio_search(query)
    geocodio_api_key = ENV.fetch('GEOCODIO_API_KEY', Rails.application.credentials[:GEOCODIO_API_KEY])
    raise ArgumentError 'Missing GEOCODIO_API_KEY' if geocodio_api_key.blank?

    geocodio = Geocodio::Gem.new(geocodio_api_key)
    geocodio.geocode(query, ['cd'])
  end

  # NOTE: This info only grabs data for the most likely represenative district
  # given a search. It would be good to adapt this to show all possible
  # matching representatives for a search / county.
  # See https://www.geocod.io/docs/#data-appends-fields
  def self.civic_api_to_representative_params(rep_info)
    reps = []
    response = rep_info['results'][0]['response']
    fields = response['results'][0]['fields']
    #checks if fields and cong_districts exist/filled
    if fields.present? && fields['congressional_districts'].present?
      #Assign cong dist in the search to districts
      districts = fields['congressional_districts']
    else
      #if no districts are found in search
      districts = []
    end
    
    districts.each do |district|
      #checks if districts and curr legis exist/filled
      if district.present? && district['current_legislators'].present?
        #Assigns all legislators for the district
        @legislators = district['current_legislators']
      else
        @legislators = []
      end
      @legislators.each_with_index do |official, _index|
        official['name'] = "#{official.dig('bio', 'first_name')} #{official.dig('bio', 'last_name')}"
        title = official['type']
        # Inspect all the data that's there to make part 1 easier.
        # Rails.logger.debug official
        # official.dig('bio', 'party')
        ocdid = official['govtrack_id']
        reps << Representative.find_rep(official, ocdid: ocdid, title: title)
      end
    end
    #returns all reps with a uniq id so multiple represenetatives arent shown more than once on the list
    reps.uniq(&:id)
  end

  def self.find_rep(official, title: '', ocdid: '')
    rep = Representative.find_or_initialize_by(ocdid: ocdid)
    rep.name = official['name'] if official['name']
    rep.title = title if title.present?
    rep.party = official['party'] if official['party']
    rep.photo_url = official['photo_url'] if official['photo_url']

    rep.save!
    rep
  end

  def update_from_geocodio(official)
    self.title = official['type']
    self.ocdid = official['govtrack_id']
    self.party = official['party']
    self.photo_url = official['photo_url']
    # TODO: store the address, phone and website
    save!
    self
  end
end
