# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern with the components needed when you want a model to be reportable
  module UserReportable
    extend ActiveSupport::Concern

    included do
      has_one :moderation, class_name: "Decidim::UserModeration", foreign_key: :decidim_user_id, dependent: :destroy
      has_many :reports, through: :moderation, class_name: "Decidim::UserReport"

      def report_count
        moderation&.report_count.to_i
      end

      # Public: Check if the user has reported the reportable.
      #
      # Returns Boolean.
      def reported_by?(user)
        reports.where(user:).any?
      end

      # Public: Checks if the reportable has been reported or not.
      #
      # Returns Boolean.
      def reported?
        report_count&.positive?
      end
    end
  end
end
