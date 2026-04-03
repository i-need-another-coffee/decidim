# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module Templates
    # This is the engine that runs on the public interface of templates.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Templates

      routes do
        # Add engine routes here
        resources :templates
        # root to: "templates#index"
      end

      initializer "decidim_templates.data_migrate", after: "decidim_core.data_migrate" do
        DataMigrate.configure do |config|
          config.data_migrations_path << root.join("db/data").to_s
        end
      end

      initializer "decidim_templates.assets" do |app|
        app.config.assets.paths << root.join("app/javascript")
      end

      initializer "decidim_templates.importmaps", before: "importmap" do |app|
        app.config.importmap.paths << root.join("config/importmap.rb")
        app.config.importmap.cache_sweepers << root.join("app/javascript")
      end

      initializer "decidim_templates.shakapacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end
    end
  end
end
