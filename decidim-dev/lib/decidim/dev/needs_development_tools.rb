# frozen_string_literal: true

module Decidim
  module Dev
    # This concern adds development tools, such as the accessibility checks
    # to the views where this is included for development purposes. This should
    # be only included in the development environment.
    module NeedsDevelopmentTools
      extend ActiveSupport::Concern

      included do
        before_action :apply_development_tools
      end

      private

      def apply_development_tools
        return unless respond_to?(:snippets)

        snippets.add(:head, helpers.stylesheet_pack_tag("decidim_dev"))
        snippets.add(:foot, helpers.javascript_pack_tag("decidim_dev", defer: false))

        return unless defined?(::Debugbar)

        return unless ::Debugbar.config.enabled?

        snippets.add(:head, helpers.javascript_include_tag("/_debugbar/assets/script", defer: :defer))
        snippets.add(:foot, debug_bar)
      end

      def debug_bar
        div = helpers.content_tag(:div, nil, id: "__debugbar", data: { "turbo-permanent" => true })

        js = <<~JS
          window._debugbarConfigOptions = {
            mode: "poll",
            poll: {
              url: "//" + document.location.host,
              interval: 1000
            }
          }
        JS

        js = helpers.javascript_tag(js.html_safe, data: { "turbo-permanent" => true })

        div.concat(js)
      end
    end
  end
end
