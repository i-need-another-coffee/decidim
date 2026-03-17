# frozen_string_literal: true

module Decidim
  module System
    # This command deals with destroying an application from the admin panel.
    class DestroyOrganization < Decidim::Command
      # Public: Initializes the command.
      #
      # form - A form object with the params.
      def initialize(id, form)
        @organization_id = id
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form was not valid and we could not proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid?

        organization.update!(deleted_at: Time.zone.now)
        DestroyOrganizationJob.perform_later(@organization_id)

        broadcast(:ok)
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
        broadcast(:invalid)
      end

      private

      attr_reader :form, :organization_id

      def organization
        @organization ||= Decidim::Organization.find(organization_id)
      end
    end
  end
end
