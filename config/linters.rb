# frozen_string_literal: true

CI.run do
  step "Normalize locales", "bundle exec i18n-tasks normalize --locales en"
  step "Detect unused i18n locales", "bundle exec i18n-tasks unused --locales en"
  step "Detect missing i18n keys", "ENFORCED_LOCALES=en bundle exec i18n-tasks missing --locales en"
  step "Linter: markdownlint", "npm run markdownlint"
  step "Linter: stylelint", "npm run stylelint"
  step "Linter: linthtml", "npm run linthtml"
  step "Linter: lint JS", "npm run lint"
  step "Linter: prettify JS", "npm run prettify"
  step "Linter: rubocop", "bundle exec rubocop -a"
  step "Linter: erblint", "./.github/run_erblint.sh"
end
