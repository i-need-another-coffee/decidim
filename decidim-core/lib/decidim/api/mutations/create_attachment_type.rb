# frozen_string_literal: true

module Decidim
  module Core
    class CreateAttachmentType < Decidim::Api::Types::BaseMutation
      description "Creates an attachment"
      type Decidim::Core::AttachmentType

      argument :attributes, AttachmentAttributes, description: "input attributes to create an attachment", required: true

      def resolve(attributes:)
        params = extract_from(attributes)


        form_attrs = params.merge(
          file: attributes.file.blob.signed_id,
          attachment_collection_id: attributes.collection&.id_value
        )
        form = form(Admin::AttachmentForm).from_params(form_attrs, attached_to: object)

        attachment = nil
        Admin::CreateAttachment.call(form, object) do
          on(:ok) do
            return @attachment
          end

          on(:invalid) do
            raise Decidim::Api::Errors::AttributeValidationError, form.errors
          end
        end
        return attachment if attachment.present?

        raise Decidim::Api::Errors::AttributeValidationError, form.errors if form.errors.any?

        GraphQL::ExecutionError.new(
          I18n.t("decidim.admin.attachments.create.error")
        )
      end

      def authorized?(attributes:)
        context[:scope] = :admin

        context[:attached_to] = object
        unless super && allowed_to?(:create, :attachment, nil, context)
          raise Decidim::Api::Errors::MutationNotAuthorizedError, I18n.t("decidim.api.errors.unauthorized_mutation")
        end


        true
      end

      def extract_from(attributes)
        validate_multiple_locales(attributes, :title)
        validate_multiple_locales(attributes, :description)

        attributes = attributes.to_h

        attributes[:title] = attributes.to_h.fetch(:title, {})
        attributes[:description] = attributes.to_h.fetch(:description, {})

        attributes
      end
    end
  end
end
