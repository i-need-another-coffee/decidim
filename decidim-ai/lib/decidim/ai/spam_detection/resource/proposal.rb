# frozen_string_literal: true

module Decidim
  module Ai
    module SpamDetection
      module Resource
        class Proposal < Base
          def fields = [:body, :title]

          protected

          def model = Decidim::Proposals::Proposal
        end
      end
    end
  end
end
