module Decidim
  module TranslationAddons
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::TranslationAddons

      initializer "decidim_translation_addons.deface" do
        Rails.application.configure do
          config.deface.enabled = true
        end
      end

      initializer "decidim_translation_addons.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::TranslationAddons::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::TranslationAddons::Engine.root}/app/views") # for partials
      end

    end
  end
end
