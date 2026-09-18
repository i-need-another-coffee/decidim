# frozen_string_literal: true

module Decidim
  module Ai
    module SpamDetection
      class GenericSpamAnalyzerJob < ApplicationJob
        include Decidim::TranslatableAttributes

        def perform(reportable, author, locale, fields)
          @author = author
          @organization = reportable.organization

          overall_score = I18n.with_locale(locale) do
            fields.map do |field|
              classifier.classify(translated_attribute(reportable.send(field)))
              classifier.score
            end
          end

          overall_score = overall_score.inject(0.0, :+) / overall_score.size

          if overall_score >= Decidim::Ai::SpamDetection.resource_score_threshold
            Decidim::Ai.logger "#{reportable.class.name} #{reportable.id} scored #{overall_score}. Marking as spam."
            Decidim::CreateReport.call(form, reportable)
          else
            Decidim::Ai.logger "#{reportable.class.name} #{reportable.id} scored #{overall_score}. Ignoring."
          end
        end

        private

        def form
          @form ||= Decidim::ReportForm.new(
            reason: "spam",
            details: classifier.classification_log,
            hide: Decidim::Ai::SpamDetection.hide_reported_resources_automatically
          ).with_context(
            current_user: reporting_user,
            can_hide: false,
            marked_as_spam: true
          )
        end

        def reporting_user
          @reporting_user ||= Decidim::User.find_by!(email: Decidim::Ai::SpamDetection.reporting_user_email, organization: @organization)
        end
      end
    end
  end
end
