# frozen_string_literal: true

module Decidim
  module TranslationAddons
    class ReportTranslationButtonCell < ButtonCell
      include ActionView::Helpers::FormOptionsHelper

      def flag_translation_modal
        return render :already_reported_modal if already_reported_resource?
        render
      end

      def translatable_fields
        model.class.translatable_fields_list || []
      end

      private

      def user_entity?
        (model.respond_to?(:creator_author) && model.creator_author.respond_to?(:nickname)) ||
          (model.respond_to?(:author) && model.author.respond_to?(:nickname))
      end

      def cache_hash
        hash = []
        hash.push(I18n.locale)
        hash.push(only_button? ? 1 : 0)
        hash.push(current_user.try(:id))
        hash.push(model.reported_by?(current_user) ? 1 : 0)
        hash.push(model.class.name.gsub("::", ":"))
        hash.push(model.id)
        hash.join(Decidim.cache_key_separator)
      end

      def only_button?
        options[:only_button]
      end

      def modal_id
        options[:modal_id] || "flagTranslationModal"
      end

      def user_reportable?
        model.is_a?(Decidim::UserReportable)
      end

      def translation_report_form
        @report_form ||= Decidim::TranslationAddons::ReportTranslationForm.from_params(reason: "missing")
      end

      def report_translation_path
        @report_path ||= user_reportable? ? decidim.report_user_path(sgid: model.to_sgid.to_s) : Decidim::TranslationAddons::Engine.routes.url_helpers.translation_report_path(sgid: model.to_sgid.to_s)
      end

      def builder
        Decidim::FormBuilder
      end

      def button_classes
        options[:button_classes] || "button button__sm button__text button__text-secondary"
      end

      def text
        t("decidim.shared.flag_modal.translation.report_translation")
      end

      def icon_name
        "flag-line"
      end

      def html_options
        { data: { "dialog-open": current_user ? modal_id : "loginModal" } }
      end

      def field_label(field)
        field.name.gsub("_", " ").capitalize
      end

      def already_reported?(field)
        Decidim::TranslationAddons::Report.exists?(decidim_resource_id: model&.id, decidim_user_id: current_user&.id, field_name: field, locale: current_user&.locale)
      end

      def already_reported_resource?
        already_reported_fields = Decidim::TranslationAddons::Report.where(decidim_resource_id: model&.id, decidim_user_id: current_user&.id, locale: current_user&.locale).count
        return true if already_reported_fields == translatable_fields.count
        false
      end
    end
  end
end
