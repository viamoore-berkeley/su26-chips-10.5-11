# frozen_string_literal: true

class AddDetailsToRepresentatives < ActiveRecord::Migration[7.2]
  def change
    add_column :representatives, :bioguide_id, :string
    add_column :representatives, :office_address, :string
    add_column :representatives, :phone, :string
    add_column :representatives, :website, :string
    add_column :representatives, :contact_form, :string
    add_column :representatives, :twitter, :string
    add_column :representatives, :facebook, :string
    add_column :representatives, :youtube, :string
  end
end
