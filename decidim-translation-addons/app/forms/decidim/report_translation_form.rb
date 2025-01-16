# frozen_string_literal: true

module Decidim
  # A form object to be used when public users want to report a translation for a resource.
  class ReportTranslationForm < Decidim::Form
    mimic :report #Put report_translation model

    attribute :fields, String
    attribute :details, String
    validates :reason, inclusion: { in: Report::REASONS } # Add "wrong_translation" to REASON on TranslationReport Model
  end
end

