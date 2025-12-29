# frozen_string_literal: true

module Decidim
  class DestroyOrganizationJob < ApplicationJob
    queue_as :default
    def perform(organization_id)
      PaperTrail.request.enabled = false

      organization = Decidim::Organization.find(organization_id)

      organization.users.find_each do |user|
        Decidim::Report.where(decidim_user_id: user.id).destroy_all
        Decidim::Verifications::Conflict.where(current_user_id: user.id).destroy_all
        Decidim::UserBlock.where(decidim_user_id: user.id).destroy_all
        Decidim::UserBlock.where(blocking_user_id: user.id).destroy_all
        Decidim::Authorization.where(decidim_user_id: user.id).find_each do |authorization|
          authorization.destroy!
          authorization.versions.delete_all
        end
        Decidim::UserModeration.where(decidim_user_id: user.id).find_each do |moderation|
          moderation.destroy!
          moderation.versions.delete_all
        end
        Decidim::UserReport.where(user_id: user.id).destroy_all
        Decidim::Comments::Comment.where(decidim_author_id: user.id).find_each do |comment|
          comment.destroy!
          comment.versions.delete_all
        end
        Decidim::Amendment.where(decidim_user_id: user.id).destroy_all
        Decidim::Coauthorship.where(decidim_author_id: user.id).destroy_all
        Decidim::ImpersonationLog.where(decidim_user_id: user.id).destroy_all
        user.destroy!
        user.versions.delete_all
      end

      organization.static_pages.delete_all
      organization.newsletters.find_each do |newsletter|
        newsletter.destroy!
        newsletter.versions.delete_all
      end

      Decidim.participatory_space_manifests.collect(&:model_class_name).each do |model_class_name|
        klass = model_class_name.constantize

        scoped = (klass.respond_to?(:with_deleted) ? klass.with_deleted : klass).where(organization:)

        scoped.find_each do |space|
          space.manifest.run_hooks(:purge, space)
        end
      end

      Decidim::SearchableResource.where(organization:).delete_all

      if Decidim.module_installed?(:templates)
        organization.templates.find_each do |template|
          template.templatable.destroy!
          template.destroy!
        end
      end

      organization.really_destroy!
      organization.versions.delete_all

      PaperTrail.request.enabled = true
    end
  end
end
