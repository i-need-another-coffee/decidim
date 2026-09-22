# frozen_string_literal: true

module Decidim
  # Helpers related to image rendering
  module PictureHelper
    # Public: Renders an image with an AVIF <source> when the AVIF
    # representation of the given uploader is available, wrapped in a
    # <picture> element. When it is not, a plain <img> tag is rendered so
    # that the output is exactly the same as image_tag.
    #
    # uploader - The uploader instance of the attached image.
    # variant_key - The variant key to render (nil for the original size).
    # options - a Hash with options passed to the <img> tag (alt, class,
    #   loading, width, height, ...).
    #
    # Returns an HTML <picture> or <img> tag.
    def decidim_picture_tag(uploader, variant_key = nil, options = {})
      sources = uploader.picture_sources(variant_key)
      fallback = uploader.fallback_url(variant_key)

      return image_tag(fallback, **options) if sources.empty?

      tag.picture do
        safe_join(
          sources.map { |source| tag.source(srcset: source[:src], type: source[:type]) } +
            [image_tag(fallback, **options)],
          ""
        )
      end
    end
  end
end
