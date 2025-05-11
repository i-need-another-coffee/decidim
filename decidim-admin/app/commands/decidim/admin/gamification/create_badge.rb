# frozen_string_literal: true

module Decidim
  module Admin
    module Gamification
      class CreateBadge < Decidim::Command
        def initialize(organization, manifest_name)
          @organization = organization
          @manifest_name = manifest_name
        end

        def call
          create_badge
          broadcast(:ok)
        rescue StandardError
          broadcast(:invalid)
        end

        private

        attr_reader :organization, :manifest_name

        def create_badge
          Decidim::Gamification::Badge.create!(
            organization:,
            manifest_name:
          )
        end
      end
    end
  end
end
