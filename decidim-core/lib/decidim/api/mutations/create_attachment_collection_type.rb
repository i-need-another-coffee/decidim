# frozen_string_literal: true

module Decidim
  module Core
    class CreateAttachmentCollectionType < Decidim::Api::Types::BaseMutation
      description "Creates an attachment collection"
      type Decidim::Core::AttachmentCollectionType

      argument :attributes, AttachmentCollectionAttributes, description: "input attributes to create an attachment collection", required: true

      def resolve(attributes:)
        params = extract_from(attributes)

        key = params.fetch(:key) || params.fetch(:slug)
        form = form(Admin::AttachmentCollectionForm).from_params(params.merge(key:), collection_for: object)

        attachment_collection = nil
        Decidim::Admin::CreateAttachmentCollection.call(form, object) do
          on(:ok) do
            return @attachment_collection
          end
        end
        return attachment_collection if attachment_collection.present?

        raise Decidim::Api::Errors::AttributeValidationError, form.errors if form.errors.any?

        GraphQL::ExecutionError.new(
          I18n.t("decidim.admin.attachment_collections.create.error")
        )
      end

      def authorized?(attributes:)
        unless super && allowed_to?(:create, :attachment_collection, nil, context)
          raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation")
        end

        true
      end

      def extract_from(attributes)
        validate_multiple_locales(attributes, :name)
        validate_multiple_locales(attributes, :description)

        attributes = attributes.to_h

        attributes[:name] = attributes.to_h.fetch(:name, {})
        attributes[:description] = attributes.to_h.fetch(:description, {})

        attributes
      end
    end
  end
end
