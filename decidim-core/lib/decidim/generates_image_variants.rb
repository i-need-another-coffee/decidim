# frozen_string_literal: true

require "active_support/concern"

module Decidim
  # A concern for models that have image attachments for which the AVIF
  # variants should be generated asynchronously. The job is enqueued with
  # after_commit so that rolled back saves do not trigger it, and only when
  # the attachment actually changed.
  module GeneratesImageVariants
    extend ActiveSupport::Concern

    included do
      class_attribute :image_variant_attachments, instance_writer: false, default: []

      before_save :decidim_snapshot_attachment_blob_ids
      after_commit :enqueue_image_variant_generation, on: [:create, :update]
    end

    class_methods do
      # Registers the attachment names for which the image variant
      # generation job is enqueued when the attachment changes.
      #
      #   generates_image_variants_for :logo, :favicon
      def generates_image_variants_for(*attachment_names)
        self.image_variant_attachments =
          (image_variant_attachments + attachment_names.map(&:to_sym)).uniq
      end
    end

    private

    # Snapshots the blob ids of the registered attachments that have a
    # pending change, so that the after_commit callback can detect which
    # ones changed. has_one_attached does not store a *_attachment_id
    # column on the model, so the change cannot be detected through
    # saved_change_to_attribute?.
    def decidim_snapshot_attachment_blob_ids
      @decidim_attachment_blob_ids = nil
      return unless Decidim.avif_images_enabled
      return if attachment_changes.empty?

      self.class.image_variant_attachments.each do |name|
        next unless attachment_changes.has_key?(name.to_s)
        next unless respond_to?(name)

        @decidim_attachment_blob_ids ||= {}
        @decidim_attachment_blob_ids[name] = public_send("#{name}_attachment")&.blob_id
      end
    end

    # Enqueues the generation of the AVIF variants for the attached images
    # that changed on the last save.
    def enqueue_image_variant_generation
      previous_blob_ids = @decidim_attachment_blob_ids
      @decidim_attachment_blob_ids = nil
      return unless previous_blob_ids
      return unless Decidim.avif_images_enabled

      previous_blob_ids.each do |name, previous_blob_id|
        # The association may have been loaded before the save with the old
        # attachment, so it is reloaded to read the post-save state.
        current_blob_id = association("#{name}_attachment").reload.target&.blob_id
        next if previous_blob_id == current_blob_id

        Decidim::GenerateImageVariantsJob.perform_later(self.class.name, id, name.to_s)
      end
    end
  end
end
