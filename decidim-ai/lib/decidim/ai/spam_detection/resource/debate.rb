# frozen_string_literal: true

module Decidim
  module Ai
    module SpamDetection
      module Resource
        class Debate < Base
          def fields = [:description, :title]

          protected

          def model = Decidim::Debates::Debate
        end
      end
    end
  end
end
