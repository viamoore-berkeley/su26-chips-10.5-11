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

  let(:official) do
    {
      'type' => 'senator',
      'bio' => { 'first_name' => 'Jane', 'last_name' => 'Doe', 'party' => 'Democrat' },
      'contact' => { 'phone' => '202-555-0100' },
      'references' => { 'govtrack_id' => '2', 'bioguide_id' => 'D000197' }
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
      described_class.create!(ocdid: '2', title: 'old title')
      rep = described_class.find_rep(official, title: 'senator', ocdid: '2')
      expect(rep).to have_attributes(title: 'senator', name: 'Jane Doe', party: 'Democrat', phone: '202-555-0100')
    end
  end

  describe 'update_from_geocodio' do
    it 'updates representative fields from geocodio correctly' do
      rep = described_class.create!(name: 'Old Name', ocdid: '1', title: 'old title')
      rep.update_from_geocodio(official)
      expect(rep).to have_attributes(title: 'senator', ocdid: '2', name: 'Jane Doe', party: 'Democrat')
    end
  end

  describe 'geocodio_search (network stubbed)' do
    let(:geocodio_body) { Rails.root.join('spec/fixtures/geocodio_response.json').read }

    before do
      stub_request(:post, /api\.geocod\.io/).to_return(
        status: 200,
        body: geocodio_body,
        headers: { 'Content-Type' => 'application/json' }
      )
    end

    it 'fetches and parses representatives without hitting the network' do
      data = described_class.geocodio_search('1234 Main St')
      reps = described_class.civic_api_to_representative_params(data)
      expect(reps.first).to have_attributes(name: 'Jane Doe', party: 'Democrat', phone: '202-555-0100')
    end
  end
end
