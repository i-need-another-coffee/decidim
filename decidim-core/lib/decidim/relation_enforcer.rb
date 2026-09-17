# frozen_string_literal: true

module Decidim
  module RelationEnforcer
    module Model
      extend ActiveSupport::Concern

      included do
        class_attribute :enforced_attribute
        class_attribute :enforcement_disabled
      end

      class_methods do
        def enforces(attribute)
          self.enforced_attribute = attribute
        end

        def self.enforcement_disabled?
          self.enforcement_disabled.present?
        end

        def enforced?
          [enforced_attribute.present?, enforcement_disabled.nil?].all?
        end

        def with_enforcement_disabled
          previous_state = enforcement_disabled
          begin
            self.enforcement_disabled = true
            yield
          ensure
            self.enforcement_disabled = previous_state
          end
        end
      end
    end

    module Relation
      def exec_queries(*args)
        conditions = [
          Rails.env.local?,
          klass.respond_to?(:enforced?) && klass.enforced?
        ]

        if conditions.all?
          where_sql = arel.constraints.map(&:to_sql).join(" ")

          association_reflection = klass.reflect_on_association(klass.enforced_attribute)

          raise ArgumentError, "Association :#{klass.enforced_attribute} not found on #{klass.name}" if association_reflection.nil?

          needed_field = association_reflection.foreign_key
          expected_column = "\"#{klass.table_name}\".\"#{needed_field}\""

          raise SecurityError, "Security Violation: Query for #{klass.name} missing compulsory `#{klass.enforced_attribute}` filter!" unless where_sql.include?(expected_column)
        end

        super
      end
    end
  end
end
