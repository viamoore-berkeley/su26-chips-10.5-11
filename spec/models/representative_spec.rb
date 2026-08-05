# frozen_string_literal: true

# == Schema Information
#
# Table name: representatives
#
#  id         :integer          not null, primary key
#  city       :string
#  name       :string
#  ocdid      :string
#  party      :string
#  photo_url  :string
#  state      :string
#  street     :string
#  title      :string
#  zip        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'rails_helper'

# This file is a stub.
# You should add your own test cases.
# We recommend creating a file for each model in the database.
# found describe structure at: https://rspec.info/features/3-12/rspec-core/example-groups/basic-structure/
RSpec.describe Representative do
  describe 'civic_api' do
    it 'searches for the correct representative' do
      rep_info = {
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
      rep = Representative.civic_api_to_representative_params(rep_info)
      expect(rep.length).to eq(1)
      expect(rep.first.name).to eq('Jane Doe')
    end

    it 'checks if empty' do
      rep_info = {
        'results' => [{
          'response' => {
            'results' => [{
              'fields' => {}
            }]
          }
        }]
      }
      rep = Representative.civic_api_to_representative_params(rep_info)
      expect(rep).to be_empty
    end
  end
end
