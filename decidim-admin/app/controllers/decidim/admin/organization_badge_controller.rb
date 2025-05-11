# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing the organization badges
    class OrganizationBadgeController < Decidim::Admin::ApplicationController
      layout "decidim/admin/settings"

      add_breadcrumb_item_from_menu :admin_settings_menu

      def edit
        enforce_permission_to_update_resource
      end

      def update
        enforce_permission_to_update_resource

        Decidim::Admin::Gamification::ReorderBadges.call(current_organization, params[:ids_order]) do
          on(:ok) do
            head :ok
          end
          on(:invalid) do
            head :bad_request
          end
        end
      end

      helper_method :content_blocks_title, :add_content_block_text,
                    :available_manifests, :resource_create_url, :active_blocks,
                    :active_content_blocks_title, :resource_sort_url,
                    :inactive_content_blocks_title, :inactive_blocks,
                    :resource_content_block_cell, :content_block_destroy_confirmation_text

      def content_block_destroy_confirmation_text
        "Are you sure you want to destroy the badge?"
      end

      private

      def enforce_permission_to_update_resource
        enforce_permission_to :update, :organization, organization: current_organization
      end

      def content_blocks_title
        "Edit badges"
      end

      def add_content_block_text
        "Add badges"
      end

      def active_content_blocks_title
        "Active badges"
      end

      def inactive_content_blocks_title
        "Inactive badges"
      end

      def available_manifests
        @available_manifests ||= Decidim::Gamification.badge_registry.all
      end

      def resource_create_url(manifest_name)
        organization_badge_badges_path(manifest_name:)
      end

      def resource_sort_url
        organization_badge_path
      end

      def active_blocks
        badges.published
      end

      def inactive_blocks
        badges.unpublished
      end

      def badges
        @badges ||= Decidim::Gamification::Badge.where(organization: current_organization)
      end

      def resource_content_block_cell
        "decidim/admin/organization_badge"
      end
    end
  end
end
