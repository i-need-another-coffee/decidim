# frozen_string_literal: true

module Decidim
  module TranslationAddons
    class Report < ApplicationRecord
      REASONS = %w(missing wrong).freeze
      belongs_to :resource, foreign_key: "decidim_resource_id", foreign_type: "decidim_resource_type", polymorphic: true
      belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"
      validates :decidim_resource_id, uniqueness: { scope: [:decidim_resource_type, :field_name, :locale, :decidim_user_id] }
      validates :reason, presence: true
    end
  end
end
