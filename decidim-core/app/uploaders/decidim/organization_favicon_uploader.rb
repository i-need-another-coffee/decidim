# frozen_string_literal: true

module Decidim
  # This class deals with uploading an organization's favicon.
  class OrganizationFaviconUploader < ImageUploader
    SIZES = {
      huge: 512,
      big: 192,
      medium: 180,
      small: 32
    }.freeze

    set_variants do
      SIZES.transform_values do |value|
        {
          resize_and_pad: [value, value],
          format: :png
        }
      end.merge(
        # Libvips does not support the ImageMagick-specific define option, nor does it natively support
        # generating multi-resolution (multi-layer) .ico files from a single command like auto-resize.
        # While it can read them (using ImageMagick internally), it does not have a "saver" to generate them.
        favicon: {
          resize_and_pad: [256, 256],
          format: :png
        }
      )
    end

    def extension_allowlist
      %w(png jpg jpeg webp)
    end
  end
end
