# frozen_string_literal: true

module Decidim
  module RelationEnforcer
    module Model
      extend ActiveSupport::Concern

      included do
        class_attribute :enforced_attribute
      end

      class_methods do
        def enforces(attribute)
          self.enforced_attribute = attribute
        end

        def enforced?
          enforced_attribute.present?
        end
      end
    end

    module Relation
      def exec_queries(*args)
        if Rails.env.local? && klass.respond_to?(:enforced?) && klass.enforced?
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
