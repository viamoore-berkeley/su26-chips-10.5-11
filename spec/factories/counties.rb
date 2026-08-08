# frozen_string_literal: true

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
