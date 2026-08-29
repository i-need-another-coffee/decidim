# frozen_string_literal: true

module Decidim
  module ImageHelper
    def decidim_picture_tag(model, mounted_as, variant: nil, **options)
      return unless model.respond_to?(mounted_as)
      return if model.send(mounted_as).blank?
      return unless model.respond_to?(:attached_uploader)

      uploader = model.attached_uploader(mounted_as)

      pictures = [
        uploader.avif_url(variant),
        uploader.url(variant:)
      ].compact_blank

      if pictures.empty?
        image_tag(uploader.default_url, options.delete(:image)) if uploader.respond_to?(:default_url)
      else
        picture_tag(pictures, options)
      end
    end
  end
end
