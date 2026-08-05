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
require 'rails_helper'

RSpec.describe County do
  before do
    bama_attributes = {
      name:         'Alabama',
      symbol:       'AL',
      fips_code:    '01',
      is_territory: 0,
      lat_min:      '-88.473227',
      lat_max:      '-84.88908',
      long_min:     '30.223334',
      long_max:     '-84.88908'
    }
    @sweet_home = described_class.create!(bama_attributes)
    @Autauga = @sweet_home.counties.create!({ name:       'Autauga County',
                                   fips_code:  5,
                                   fips_class: 69 })
  end

  it 'fips_code properly left justifies' do
    expect(@Autauga.std_fips_code).to eq '005'
  end
end
