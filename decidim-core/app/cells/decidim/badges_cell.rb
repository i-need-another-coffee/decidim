# frozen_string_literal: true

module Decidim
  class BadgesCell < Decidim::ViewModel
    include Decidim::Core::Engine.routes.url_helpers

    def available_badges
      Decidim::Gamification::Badge.where(organization: current_organization).published.select do |badge|
        badge.manifest.valid_for?(model)
      end
    end
  end
end
