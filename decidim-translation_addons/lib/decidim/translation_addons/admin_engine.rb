# frozen_string_literal: true

require "decidim/translation_addons/menu"

module Decidim
  module TranslationAddons
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::TranslationAddons::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        scope "/translation_addons" do
          resource :reports, only: [:index], controller: "reports"
        end
      end

      initializer "decidim_translation_addons_admin.routing" do
        Decidim::Core::Engine.routes do
          mount Decidim::TranslationAddons::AdminEngine, at: "/admin", as: "decidim_admin_translation_addons"
        end
      end

      initializer "decidim_translation_addons_admin.menu" do
        Decidim::TranslationAddons::Menu.register_admin_global_moderation_menu!
      end
    end
  end
end
