Feature: Accessibility
    So that all users can use our app, and we do not get sued,
    all pages should meet full accessibility standards.

# Accessibility Testing Relies on a Gem Called 'axe'
# axe uses JavaScript to audit pages for compliance with web standards.
# See https://github.com/dequelabs/axe-core-gems/blob/develop/packages/axe-core-cucumber/README.md

## These tests are excluded by default when running cucumber (see config/cucumber.yml)
#  Run cucumber -p a11y to run the 'a11y' profile

@a11y
Scenario: The Homepage
    Given I am on the homepage
    Then the page should be axe clean

@a11y
Scenario: The Login Page
    Given I am on the login page
    # e.g. enable steps like this for debugging.
    # Then show me the page
    Then the page should be axe clean

@a11y
Scenario: The Representatives Page
    Given I am on the representatives page
    Then the page should be axe clean

## Iteration 1:
## You may want to set up conditions like searching for data, etc.

@a11y
Scenario: County Representative Search Page
    Given I am on the search page for "Alameda County"
    Then the page should be axe clean

@a11y
Scenario: Events Page
    Given I am on the events page
    Then the page should be axe clean

## Iteration 2:
@a11y
Scenario: New NewsItem Page
    Given I am on a new news item page
    Then the page should be axe clean


@a11y
Scenario: Edit NewsItem Page
    Given I am on a page to edit a news item
    Then the page should be axe clean