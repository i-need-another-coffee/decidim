# frozen_string_literal: true

module Decidim
  # A form object to be used when public users want to report a translation for a resource.
  module TranslationAddons
    class ReportTranslationForm < Decidim::Form
      mimic :report

      attribute :field, String #F ield that was reported
      attribute :detail, String #Fix suggestion
      attribute :reason, String # Reason for reporting: missing/wrong translation
      attribute :field_translation, String # Current value for the reported field
      attribute :locale, String # Current locale of the report
      validates :details, presence: true, if: ->(form) { form.reason == Decidim::TranslationAddons::Report::REASONS[1] } # Work in progress
    end
  end
end
