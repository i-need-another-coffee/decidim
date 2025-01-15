module Decidim
  module TranslationAddons
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
