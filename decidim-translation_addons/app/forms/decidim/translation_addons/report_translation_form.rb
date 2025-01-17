# frozen_string_literal: true

module Decidim
  # A form object to be used when public users want to report a translation for a resource.
  module TranslationAddons
    class ReportTranslationForm < Decidim::Form
      mimic :report # Put report_translation model

      attribute :fields, String
      attribute :details, String
      validates :reason, inclusion: { in: Decidim::TranslationAddons::Report::REASONS } # Add "wrong_translation" to REASON on TranslationReport Model
      validates :at_least_one
    end
  end
end
