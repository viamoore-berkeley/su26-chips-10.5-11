# frozen_string_literal: true

# == Schema Information
#
# Table name: counties
#
#  id         :integer          not null, primary key
#  fips_class :string(2)        not null
#  fips_code  :integer          not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  state_id   :integer          not null
#
# Indexes
#
#  index_counties_on_state_id  (state_id)
#
FactoryBot.define do
  factory :county do
    name { 'Alameda' }
    fips_code { 1 }
    fips_class { 'CA' }
    state
  end

  factory :alpine_county, class: 'County' do
    name { 'Alpine' }
    fips_code { 3 }
    fips_class { 'CA' }
    state
  end
end
