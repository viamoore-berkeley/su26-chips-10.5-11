Feature: ActionMap Shows State and County Maps

Scenario: Navigating States and counties
  Given I am on the homepage
  Then I should see "National Map"
  Then I should see 50 states
  When I click the state "CA"
  Then I should see "California"
  And I should be on the state page for "CA"

Scenario: Selecting a county
  Given I am on the state page for "CA"
  Then I click the county "Alameda County"
  Then I should be on the search page for "Alameda County"

Scenario: Display correct number of states and counties
  Given I am on the state page for "CA"
  Then I should see 58 counties