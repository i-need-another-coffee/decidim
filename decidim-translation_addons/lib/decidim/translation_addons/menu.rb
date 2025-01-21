# frozen_string_literal: true

module Decidim
  module TranslationAddons
    class Menu
      def self.register_admin_global_moderation_menu!
        Decidim.menu :admin_global_moderation_menu do |menu|
          byebug
          caption = "Test"

          menu.add_item :translation_moderation,
                        caption.html_safe,
                        decidim_admin_translation_addons.reports_path,
                        position: 1,
                        active: is_active_link?(decidim_admin_translation_addons.reports_path)
        end
      end
    end
  end
end
