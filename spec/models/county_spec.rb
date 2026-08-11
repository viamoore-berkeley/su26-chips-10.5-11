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
    @sweet_home = State.create!(bama_attributes)
    @autauga = @sweet_home.counties.create!({ name:       'Autauga County',
                                   fips_code:  5,
                                   fips_class: 69 })
  end

  it 'fips_code properly left justifies' do
    expect(@autauga.std_fips_code).to eq '005'
  end
end
