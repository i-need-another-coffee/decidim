# frozen_string_literal: true

module Decidim
  module System
    class DestroyOrganizationController < Decidim::System::ApplicationController
      helper_method :current_organization

      def index
        @form = form(DestroyOrganizationForm).from_model(current_organization)
      end

      def destroy
        @form = form(DestroyOrganizationForm).from_params(params)

        DestroyOrganization.call(params[:organization_id], @form) do
          on(:ok) do
            flash[:notice] = t("organizations.destroy.success", scope: "decidim.system")
            redirect_to organizations_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("organizations.destroy.error", scope: "decidim.system")
            render :index
          end
        end
      end

      def current_organization
        @current_organization ||= Decidim::Organization.find(params[:organization_id])
      end
    end
  end
end
