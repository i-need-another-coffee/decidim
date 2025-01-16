module Decidim
  module TranslationAddons
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::TranslationAddons

      initializer "decidim_translation_addons.deface" do
        Rails.application.configure do
          config.deface.enabled = true
        end
      end
    end
  end
end
