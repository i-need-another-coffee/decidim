# frozen_string_literal: true

module Decidim
  module Ai
    module SpamDetection
      module Resource
        class Initiative < Base
          def fields = [:description, :title]

          protected

          def model = Decidim::Initiative
        end
      end
    end
  end
end
