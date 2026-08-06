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
# found describe structure at: https://rspec.info/features/3-12/rspec-core/example-groups/basic-structure/
RSpec.describe Representative do
  let(:jane_doe_json) do
    {
      'results' => [{
        'response' => {
          'results' => [{
            'fields' => {
              'congressional_districts' => [{
                'name' => 'Congressional District 12',
                'district_number' => 12,
                'ocd_id' => 'ocd-division/country:us/state:ca/cd:12',
                'current_legislators' => [{
                  'type' => 'representative',
                  'govtrack_id' => '123',
                  'bio' => {
                    'first_name' => 'Jane',
                    'last_name' => 'Doe'
                  }
                }]
              }]
            }
          }]
        }
      }]
    }
  end

  let(:empty_json) do
    {
      'results' => [{
        'response' => {
          'results' => [{
            'fields' => {}
          }]
        }
      }]
    }
  end

  describe 'civic_api' do
    it 'searches for the correct representative' do
      rep = described_class.civic_api_to_representative_params(jane_doe_json)
      expect(rep.length).to eq(1)
      expect(rep.first.name).to eq('Jane Doe')
    end

    it 'checks if empty' do
      rep = described_class.civic_api_to_representative_params(empty_json)
      expect(rep).to be_empty
    end
  end

  describe 'find_rep' do
    it "doesn't create a duplicate representative" do
      described_class.create!(ocdid: '1')
      expect do
        described_class.find_rep({ 'name' => 'Jane Doe' }, ocdid: 1)
      end.not_to(change(described_class, :count))
    end

    it 'updates an existing representative' do
      rep = described_class.create!(ocdid: '1', title: 'old title')
      official = { 'name' => 'Jane Doe', 'party' => 'party+', 'photo_url' => 'photo+.jpg' }
      described_class.find_rep(official, title: 'title+', ocdid: 1)
      rep.reload
      expect(rep).to have_attributes(title: 'title+', name: 'Jane Doe', party: 'party+', photo_url: 'photo+.jpg')
    end
  end

  describe 'update_from_geocodio' do
    it 'updates represenative fields from geocodio correctly' do
      rep = described_class.create!(name: 'Jane Doe', ocdid: '1', title: 'old title', party: 'old party',
                                    photo_url: 'old photo')
      official = { 'type' => 'new title', 'govtrack_id' => '2', 'party' => 'new party', 'photo_url' => 'new.jpg' }
      rep.update_from_geocodio(official)
      expect(rep).to have_attributes(title: 'new title', ocdid: '2', party: 'new party', photo_url: 'new.jpg')
    end
  end
end
