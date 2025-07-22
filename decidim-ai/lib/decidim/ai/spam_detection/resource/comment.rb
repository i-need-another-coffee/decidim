# frozen_string_literal: true

module Decidim
  module Ai
    module SpamDetection
      module Resource
        class Comment < Base
          def fields = [:body]

          protected

          def model = Decidim::Comments::Comment
        end
      end
    end
  end
end
