# frozen_string_literal: true

module Decidim
  module Ai
    module SpamDetection
      module Resource
        class CollaborativeDraft < Base
          def fields = [:body, :title]

          protected

          def model = Decidim::Proposals::CollaborativeDraft
        end
      end
    end
  end
end
