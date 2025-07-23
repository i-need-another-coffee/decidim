# frozen_string_literal: true

module Decidim
  module RailsUjsHelper
    def link_to(name = nil, options = nil, html_options = nil, &block)
      html_options, options, name = options, name, block if block_given?
      options ||= {}

      html_options = convert_options_to_data_attributes(options, html_options)

      url = url_target(name, options)
      html_options["href"] ||= url

      if html_options["data-method"]
        html_options["data-turbo-method"] = html_options["data-method"]
        html_options.delete("data-method")
        Rails.logger.warn "RailsUJS: data-method is deprecated, use data-turbo-method instead"
      end

      content_tag("a", name || url, html_options, &block)
    end
  end
end
