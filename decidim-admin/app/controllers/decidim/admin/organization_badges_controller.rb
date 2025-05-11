# frozen_string_literal: true

module Decidim
  module Admin
    class OrganizationBadgesController < Decidim::Admin::ApplicationController
      layout "decidim/admin/settings"

      def create
        enforce_permission_to_update_resource

        Decidim::Admin::Gamification::CreateBadge.call(current_organization, params[:manifest_name]) do
          on(:ok) do
            flash[:success] = badge_create_success_text
          end
          on(:invalid) do
            flash[:error] = badge_create_error_text
          end

          redirect_to edit_resource_landing_page_path
        end
      end

      def destroy
        enforce_permission_to_update_resource

        Decidim::Admin::Gamification::DestroyBadge.call(badge) do
          on(:ok) do
            flash[:success] = badge_destroy_success_text
          end
          on(:invalid) do
            flash[:error] = badge_destroy_error_text
          end

          redirect_to edit_resource_landing_page_path
        end
      end

      #
      # def edit
      #   enforce_permission_to_update_resource
      #   @form = form(ContentBlockForm).from_model(badge)
      #
      #   render "decidim/admin/shared/landing_page_badges/edit"
      # end
      #
      # def update
      #   enforce_permission_to_update_resource
      #
      #   @form = form(ContentBlockForm).from_params(params)
      #
      #   UpdateContentBlock.call(@form, badge, badge_scope) do
      #     on(:ok) do
      #       redirect_to edit_resource_landing_page_path
      #     end
      #     on(:invalid) do
      #       render "decidim/admin/shared/landing_page_badges/edit"
      #     end
      #   end
      # end
      private

      def enforce_permission_to_update_resource
        enforce_permission_to :update, :organization, organization: current_organization
      end

      def edit_resource_landing_page_path
        edit_organization_badge_path
      end

      def i18n_scope = "decidim.admin.badges"

      # Method to be implemented at the controller. Returns a string
      # with the success text after creating a content block.
      #
      # i18n-tasks-use t('decidim.admin.badges.create.success')
      # Example: t("create.success", scope: "decidim.admin.badges")
      def badge_create_success_text = t("create.success", scope: i18n_scope)

      # Method to be implemented at the controller. Returns a string
      # with the success text after creating a content block.
      #
      # i18n-tasks-use t('decidim.admin.badges.create.error')
      # Example: t("create.error", scope: "decidim.admin.badges")
      def badge_create_error_text = t("create.error", scope: i18n_scope)

      # Method to be implemented at the controller. Returns a string
      # with the success text after destroying a content block.
      #
      # i18n-tasks-use t('decidim.admin.badges.destroy.success')
      # Example: t("destroy.success", scope: "decidim.admin.badges")
      def badge_destroy_success_text = t("destroy.success", scope: i18n_scope)

      # Method to be implemented at the controller. Returns a string
      # with the success text after destroying a content block.
      #
      # i18n-tasks-use t('decidim.admin.badges.destroy.error')
      # Example: t("destroy.error", scope: "decidim.admin.badges")
      def badge_destroy_error_text = t("destroy.error", scope: i18n_scope)

      # Shared methods
      def badge
        @badge ||= badges.find(params[:id])
      end

      def badges
        @badges ||= Decidim::Gamification::Badge.where(organization: current_organization)
      end
    end
  end
end
