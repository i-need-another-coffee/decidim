module Decidim
  module TranslationAddons
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::TranslationAddons

      routes do
        scope "/translation_addons" do
          resource :translation_report, only: [:create], controller: "reports"
        end
      end

      initializer "decidim_translation_addons.deface" do
        Rails.application.configure do
          config.deface.enabled = true
        end
      end

      initializer "decidim_translation_addons.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::TranslationAddons::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::TranslationAddons::Engine.root}/app/views") # for partials
      end

      # initializer "decidim_admin.menu" do
      #   Decidim::TranslationAddons::Menu.register_admin_global_moderation_menu!
      # end

      initializer "decidim_translation_addons.routing" do
        Decidim::Core::Engine.routes do
          mount Decidim::TranslationAddons::Engine => "/", :as => :translation_addons
        end
      end
    end
  end
end
