# frozen_string_literal: true

FactoryBot.define do
  factory :state do
    name { 'California' }
    symbol { 'CA' }
    fips_code { 6 }
    is_territory { 0 }
    lat_min { 32.30 }
    lat_max { 40.00 }
    long_min { 114.8 }
    long_max { 124.24 }

    factory :washington do
      name { 'Washington' }
      symbol { 'WA' }
      fips_code { 53 }
    end
  end
end
