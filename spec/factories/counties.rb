# frozen_string_literal: true

# == Schema Information
#
# Table name: counties
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  state_id   :integer          not null
#  fips_code  :integer          not null
#  fips_class :string(2)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
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
