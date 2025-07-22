# frozen_string_literal: true

module Decidim
  module Comments
    class SeedJob < Decidim::ApplicationJob
      queue_as :seeds

      def perform(resource)
        require "faker"
        require "decidim/faker/internet"
        require "decidim/faker/localized"

        ActiveRecord::Base.transaction do
          Decidim::Comments::Seed.comments_for(resource)
        end
      end
    end
  end
end
