# frozen_string_literal: true

module Decidim
  module Admin
    class OrganizationBadgeCell < ContentBlockCell
      def edit_content_block_path
        decidim_admin.edit_organization_badge_badge_path(model)
      end

      def content_block_path
        decidim_admin.organization_badge_badge_path(model)
      end

      def decidim_admin
        Decidim::Admin::Engine.routes.url_helpers
      end

      def name
        return model.manifest.translated_name if translated_attribute(model.name).empty?

        translated_attribute(model.name)
      end
    end
  end
end
