# frozen_string_literal: true

module Decidim
  module Demographics
    class DemographicsController < Decidim::Demographics::ApplicationController
      include Decidim::UserProfile

      def edit
        enforce_permission_to :update, :user, current_user: current_user

        @form = demographics_form.from_model(demographics_data)
      end

      protected


      def demographics_data
        @demographics_data || Decidim::Demographics::Demographic.where(decidim_user: current_user).first_or_initialize(data: {})
      end

      def demographics_form
        form(Decidim::Demographics::DemographicsForm)
      end
    end
  end
end
