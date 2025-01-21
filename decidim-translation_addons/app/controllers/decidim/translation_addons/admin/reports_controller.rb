# frozen_string_literal: true

module Decidim
  module TranslationAddons
    module Admin
      # Controller used to manage participatory process types for the current
      # organization
      class ReportsController < Decidim::TranslationAddons::Admin::ApplicationController
        def index
          Decidim::TranslationAddons::Report.all
        end
      end
    end
  end
end
