Feature: Can create and edit news items
  As an authenticated user
  I want to add a news
  So that users can view relevant news and issues

Background:
  Given a representative exists with name "Jane Doe"
  And I am logged in via github as "John Doe"

Scenario: Successfully adding a news item
  Given I am on the news items page for "Jane Doe"
  When I press "Add News Article"
  Then I should see "Search for News Articles"
  And I should see "Representative"
  And I should see "Issue"
  And I should see "Search"