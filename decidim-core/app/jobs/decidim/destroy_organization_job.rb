# frozen_string_literal: true

module Decidim
  class DestroyOrganizationJob < ApplicationJob
    queue_as :default
    def perform(organization_id)
      PaperTrail.request.enabled = false

      organization = Decidim::Organization.find(organization_id)

      organization.static_pages.delete_all

      Decidim.participatory_space_manifests.collect(&:model_class_name).each do |model_class_name|
        klass = model_class_name.constantize

        scoped = (klass.respond_to?(:with_deleted) ? klass.with_deleted : klass).where(organization:)

        scoped.find_each do |space|
          space.manifest.run_hooks(:purge, space)
        end
      end

      organization.users.destroy_all
      Decidim::SearchableResource.where(organization:).delete_all
      organization.really_destroy!

      PaperTrail.request.enabled = true
    end
  end
end
