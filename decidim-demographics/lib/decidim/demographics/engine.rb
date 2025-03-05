# frozen_string_literal: true

module Decidim
  module Demographics
    # This is the engine that runs on the public interface of `decidim-debates`.
    # It mostly handles rendering the created debate associated to a participatory
    # process.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Demographics

      routes do
        root to: "demographics#show"
      end

      initializer "decidim_demographics.register_admin" do
        Decidim::Core::Engine.routes do
          mount Decidim::Demographics::Engine => "/demographics", as: :demographics_engine
        end
      end

      initializer "decidim_demographics.user_menu" do
        Decidim.menu :user_menu do |menu|
          # if current_organization.demographics_data_collection?
            menu.add_item :demographics,
                          t("name", scope: "decidim.demographics"),
                          demographics_engine.root_path,
                          position: 1.0,
                          active: :exact

            menu.move :demographics, after: :download_your_data
          # end
        end
      end

      initializer "decidim_demographics.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end

