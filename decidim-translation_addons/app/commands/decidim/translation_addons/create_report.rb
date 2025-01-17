# frozen_string_literal: true

module Decidim
  module TranslationAddons
    class CreateReport < Decidim::Command
      def initialize(resource_instance, field, locale, current_user, fix_suggestion, reason = "missing") # rubocop:disable Metrics/ParameterLists
        @resource_instance = resource_instance
        @field = field
        @locale = locale
        @reason = reason
        @current_user = current_user
        @fix_suggestion = fix_suggestion
      end

      def call
        return broadcast(:invalid) if @resource_instance.blank? || @field.blank? || @locale.blank? || @current_user.blank? || @fix_suggestion.blank? || @reason.blank?

        create_report
        broadcast(:ok)
      end

      private

      attr_reader :resource_instance, :field, :locale, :current_user, :reason, :fix_suggestion

      def create_report
        @report = Decidim.traceability.perform_action!(
          :create,
          Decidim::TranslationAddons::Report,
          @current_user,
          visibility: "public-only"
        ) do
          report = Decidim::TranslationAddons::Report.new(
            decidim_user_id: current_user.id,
            decidim_resource_type: resource.class.name,
            decidim_resource_id: resource.id,
            field_name: field,
            locale: locale,
            fix_suggestion: fix_suggestion
          )

          report.save!
          report
        end
      end
    end
  end
end
