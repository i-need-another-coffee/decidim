# frozen_string_literal: true

# Handle the locale redirects in the route files
# It tries to detect a place where the locale is being present, either as a GET parameter,
# or a session, or if there is nothing it will return the default locale of the organization.
module Decidim
  class Router

    def initialize(request, params, path, options = {})
      @request = request
      @input_params = params
      @wildcard = options.delete(:wildcard)
      @locale = options.delete(:locale) || true
      @query_string_attached = options.delete(:query_string) || false
      @path = path
    end

    def self.call(request, params, path, options = {})
      new(request, params, path, options).url
    end

    def url
      url = [locale, @path, @wildcard.present? ? input_params[@wildcard] : nil].compact_blank.join("/")

      return url if query_string.blank?

      "#{url}?#{query_string}"
    end

    def locale
      available_locales.map(&:to_sym).include?(extracted_locale.to_sym) ? extracted_locale : default_locale
    end

    # Handle explicitly the query strings, as sometimes we have filters in pages like last activity, or search
    # https://nightly.decidim.org/profiles/visitant_bqqppvus/activity?filter[resource_type]=Decidim::Initiative
    def query_string
      return unless @query_string_attached
      @query_string ||= begin
              qs = Rack::Utils.parse_nested_query(request.query_string.to_s)
              qs.delete("locale")
              CGI.unescape(qs.to_query)
            end
    end

    private

    attr_reader :request, :input_params

    def extracted_locale
      input_params[:locale] || request.parameters[:locale].presence || request.session[:user_locale].presence || I18n.locale
    end

    def available_locales
      (organization || Decidim).available_locales
    end

    def default_locale
      (organization || Decidim).default_locale
    end

    def organization
      request.env["decidim.current_organization"]
    end
  end
end
