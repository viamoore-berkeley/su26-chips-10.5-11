# frozen_string_literal: true

require 'webmock/cucumber'
WebMock.disable_net_connect!(allow_localhost: true)

ENV['GEOCODIO_API_KEY'] = 'fake-key'
GEOCODIO_STUB =
  {
    results: [{
      response: {
        results: [{
          fields: {
            congressional_districts: [{
              name: 'Congressional District 12',
              district_number: 12,
              ocd_id: 'ocd-division/country:us/state:ca/cd:12',
              current_legislators: [{
                type: 'Representative',
                govtrack_id: '123',
                bio: {
                  first_name: 'Jane',
                  last_name: 'Doe'
                }
              }]
            }]
          }
        }]
      }
    }]
  }.to_json

Before do
  stub_request(:post, /api\.geocod\.io/)
    .to_return(
      status: 200,
      body: GEOCODIO_STUB,
      headers: { 'Content-Type' => 'application/json' }
    )
end
