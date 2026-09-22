# frozen_string_literal: true

module Decidim
  module Ai
    module SpamDetection
      module Resource
        class UserBaseEntity < Base
          def fields = [:about]

          def batch_train
            if model.is_a?(Decidim::UserReportable)
              query.blocked.find_each(batch_size: 100) { |resource| train_resource(:spam, resource) }
              query.not_blocked.find_each(batch_size: 100) { |resource| train_resource(:ham, resource) }
            else
              query.find_each(batch_size: 100) do |resource|
                classification = resource_hidden?(resource) ? :spam : :ham

                train_resource(classification, resource)
              end
            end
          end

          def train(category, text)
            raise error_message("Decidim::Ai::SpamDetection.user_detection_service", __method__) unless classifier.respond_to?(:train)

            classifier.train(category, text)
          end

          def untrain(category, text)
            raise error_message("Decidim::Ai::SpamDetection.user_detection_service", __method__) unless classifier.respond_to?(:untrain)

            classifier.untrain(category, text)
          end

          protected

          def model = Decidim::User
          alias query model

          def resource_hidden?(resource) = resource.class.included_modules.include?(Decidim::UserReportable) && resource.blocked?

          def classifier
            @classifier ||= Decidim::Ai::SpamDetection.user_classifier
          end
        end
      end
    end
  end
end
