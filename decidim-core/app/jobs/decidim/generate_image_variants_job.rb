# frozen_string_literal: true

module Decidim
  # Generates the AVIF representations of an attached image so that the
  # decidim_picture_tag helper can render a <picture> element with an AVIF
  # <source>. When the original file is already AVIF it generates the
  # full-size PNG fallback instead, as the size variants are already AVIF.
  #
  # Encoding failures (e.g. libvips without an AVIF encoder) are logged and
  # skipped so that the application degrades gracefully to plain <img> tags.
  class GenerateImageVariantsJob < ApplicationJob
    queue_as :active_storage

    def perform(record_type, record_id, attachment_name)
      record = record_type.constantize.find_by(id: record_id)
      return if record.nil?

      uploader = record.attached_uploader(attachment_name)
      return unless uploader.attached?

      blob = uploader.blob
      return unless blob&.image?

      context = "#{record_type} ##{record_id} (#{attachment_name})"
      ([nil] + uploader.variants.keys).each do |key|
        process_variant(uploader, blob, key, context)
      end
    rescue ActiveRecord::RecordNotFound
      # The record was deleted between enqueuing and execution.
    end

    private

    def process_variant(uploader, blob, key, context)
      if uploader.avif_blob?
        return if key.present?
        return if uploader.full_size_fallback_processed?

        blob.variant(format: :png).processed
      else
        return if uploader.avif_variant_processed?(key)

        blob.variant(uploader.class.avif_variation_spec(key)).processed
      end
    rescue Vips::Error, ActiveStorage::InvariableError, NotImplementedError, ArgumentError => e
      Rails.logger.warn(
        "Could not generate the image variant for #{context}, variant: #{key.inspect}. " \
        "The image will be served without the AVIF representation. " \
        "Error: #{e.class} #{e.message}"
      )
    end
  end
end
