# frozen_string_literal: true

module Decidim
  module Accountability
    #
    # Decorator for results
    #
    class ResultPresenter < Decidim::ResourcePresenter
      include Rails.application.routes.mounted_helpers
      include ActionView::Helpers::UrlHelper
      include Decidim::SanitizeHelper
    end
  end
end
