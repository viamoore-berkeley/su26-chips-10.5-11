# frozen_string_literal: true

# == Schema Information
#
# Table name: representatives
#
#  id         :integer          not null, primary key
#  name       :string
#  ocdid      :string
#  party      :string
#  photo_url  :string
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

# This file is a stub.
# You should add your own test cases.
# We recommend creating a file for each model in the database.

# RSpec.describe Representative do
# end

describe Representative do
  describe 'find_rep' do
    it "doesn't create a duplicate representative" do
      described_class.create!(
        ocdid: '1'
      )
      official = {
        'name' => 'Jane Doe'
      }
      expect do
        described_class.find_rep(official, ocdid: 1)
      end.not_to(change(described_class, :count))
    end

    it 'updates an existing representative' do
      rep = described_class.create!(
        ocdid: '1',
        title: 'old title'
      )

      official = {
        'name' => 'Jane Doe',
        'party' => 'new party',
        'photo_url' => 'new_photo.jpg'
      }

      described_class.find_rep(official, title: 'new title', ocdid: 1)

      rep.reload
      expect(rep.title).to eq('new title')
      expect(rep.name).to eq('Jane Doe')
      expect(rep.party).to eq('new party')
      expect(rep.photo_url).to eq('new_photo.jpg')
    end
  end

  describe 'update_from_geocodio' do
    it "updates represenative fields from geocodio correctly" do
      rep = Representative.create!(
        name: 'Jane Doe', 
        ocdid: '1',
        title: 'old title',
        party: 'old party',
        photo_url: 'old photo'
      )

      official = {
      'type' => 'new title',
      'govtrack_id' => '2',
      'party' => 'new party',
      'photo_url' => 'new.jpg'
      }

      rep.update_from_geocodio(official)
      expect(rep.title).to eq('new title')
      expect(rep.ocdid).to eq('2')
      expect(rep.party).to eq('new party')
      expect(rep.photo_url).to eq('new.jpg')
    end
  end
end

