# frozen_string_literal: true

module Decidim
  module Gamification
    class Badge < ApplicationRecord
      include Decidim::Publicable

      self.table_name = "decidim_gamification_badges"

      belongs_to :organization, foreign_key: :decidim_organization_id, class_name: "Decidim::Organization"

      delegate :has_settings?, :image, :score_descriptions, to: :manifest

      default_scope -> { order(:weight) }

      def manifest
        @manifest ||= Decidim::Gamification.badge_registry.find(manifest_name)
      end

      def settings
        manifest.settings.schema.new(self[:settings])
      end
    end
  end
end
