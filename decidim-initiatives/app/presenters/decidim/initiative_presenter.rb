# frozen_string_literal: true

module Decidim
  #
  # Decorator for initiatives
  #
  class InitiativePresenter < Decidim::ResourcePresenter
    def author
      @author ||= super.presenter
    end

    def initiative
      __getobj__
    end
  end
end
