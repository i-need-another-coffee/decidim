# frozen_string_literal: true

module Decidim
  module Design
    class ApplicationController < ::DecidimController
      include NeedsOrganization

      helper Decidim::MetaTagsHelper

      helper_method :path_items, :current_locale

      def path_items(path)
        files = Dir.glob("#{gem_path}/app/views/decidim/design/#{path}/*.html.erb")

        files.map do |file|
          name = File.basename(file, ".html.erb")
          { name:, path: send("#{path.singularize}_path", name) }
        end
      end

      private

      # The current locale for the user. Available as a helper for the views.
      #
      # Returns a String.
      def current_locale
        @current_locale ||= I18n.locale.to_s
      end

      def gem_path
        @gem_path ||= Bundler.load.specs.find { |spec| spec.name == "decidim-design" }.full_gem_path
      end
    end
  end
end
