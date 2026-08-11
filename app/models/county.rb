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
class County < ApplicationRecord
  belongs_to :state

  # Standardized FIPS code eg. 001 for 1.
  def std_fips_code
    fips_code.to_s.rjust(3, '0')
  end
end
