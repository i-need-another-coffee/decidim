# frozen_string_literal: true

module Decidim
  # This class deals with uploading files to Decidim. It is intended to just
  # hold the uploads configuration, so you should inherit from this class and
  # then tweak any configuration you need.
  class ApplicationUploader
    AVIF_CONTENT_TYPE = "image/avif"

    def initialize(model, mounted_as)
      @model = model
      @mounted_as = mounted_as
    end

    attr_reader :validable_dimensions, :model, :mounted_as, :content_type_allowlist, :content_type_denylist

    delegate :variants, to: :class

    # Override the directory where uploaded files will be stored.
    # This is a sensible default for uploaders that are meant to be mounted:
    def store_dir
      default_path = "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"

      return File.join(Decidim.base_uploads_path, default_path) if Decidim.base_uploads_path.present?

      default_path
    end

    def variant(key, format: nil)
      if key && variants[key].present?
        spec = variants[key]
        spec = spec.merge(format:) if format
        model.send(mounted_as).variant(spec)
      elsif format
        model.send(mounted_as).variant(format:)
      else
        model.send(mounted_as)
      end
    rescue ActiveStorage::InvariableError
      model.send(mounted_as)
    end

    def attached?
      model.send(mounted_as).attached?
    end

    def blob
      attachment = model.send(mounted_as)
      attachment.blob if attachment.is_a?(ActiveStorage::Attached)
    end

    def avif_blob?
      blob&.content_type == AVIF_CONTENT_TYPE
    end
    #
    # # The <source> entries for a <picture> element pointing to the AVIF
    # # representation of the attached image. Returns an empty array when the
    # # feature is disabled, no image is attached or the AVIF representation
    # # is not available, in which case a plain <img> tag should be rendered.
    # def picture_sources(key = nil)
    #   return [] unless Decidim.avif_images_enabled
    #   return [] unless attached?
    #
    #   image_blob = blob
    #   return [] unless image_blob&.image?
    #
    #   avif_blob? ? avif_picture_sources(key) : non_avif_picture_sources(key)
    # end
    #
    # # The URL to use as the <img> fallback source. For AVIF originals it
    # # returns the PNG representation, so that browsers without AVIF support
    # # still get an image.
    # def fallback_url(key = nil)
    #   return unless attached?
    #   return variant_url(key) unless avif_blob?
    #
    #   if key
    #     variant_url(key, format: :png)
    #   elsif full_size_fallback_processed?
    #     variant_url(nil, format: :png)
    #   else
    #     variant_url(nil)
    #   end
    # end
    #
    def avif_variant_processed?(key)
      blob_id = blob&.id
      return false unless blob_id

      ActiveStorage::VariantRecord.exists?(
        blob_id:,
        variation_digest: self.class.avif_variation_digest(key)
      )
    end

    def full_size_fallback_processed?
      blob_id = blob&.id
      return false unless blob_id

      ActiveStorage::VariantRecord.exists?(
        blob_id:,
        variation_digest: self.class.fallback_variation_digest
      )
    end

    def url(options = {})
      representable = model.send(mounted_as)
      return unless representable.is_a? ActiveStorage::Attached

      variant_url(options.delete(:variant), **options)
    end

    def variant_url(key, options = {})
      return unless attached?

      format = options.delete(:format)
      representable = variant(key, format:)
      AssetRouter::Storage.new(representable).url(**options)
    end

    def path(options = {})
      representable = model.send(mounted_as)
      return unless representable.is_a? ActiveStorage::Attached

      variant_path(options.delete(:variant), **options)
    end

    def variant_path(key, options = {})
      variant_url(key, **options, only_path: true)
    end

    def remote_url=(url)
      uri = URI.parse(url)
      filename = File.basename(uri.path)
      file = URI.parse(url).open
      model.send(mounted_as).attach(io: file, filename:)
    rescue URI::InvalidURIError
      model.errors.add(mounted_as, :invalid)
    end

    private

    # # The original file and its size variants are already AVIF, unless a
    # # variant spec explicitly sets another format.
    # def avif_picture_sources(key)
    #   spec = key && variants[key].present? ? variants[key] : {}
    #   format = spec[:format]
    #   return [] if format && format.to_s != "avif"
    #   return [] if key.nil? && !full_size_fallback_processed?
    #
    #   [{ src: variant_url(key), type: AVIF_CONTENT_TYPE }]
    # end
    #
    # def non_avif_picture_sources(key)
    #   return [] unless avif_variant_processed?(key)
    #
    #   [{ src: variant_url(key, format: :avif), type: AVIF_CONTENT_TYPE }]
    # end

    class << self
      # Each class inherits variants from parents and can define their own
      # variants with the set_variants class method
      def variants
        @variants ||= {}
      end

      def set_variants
        return unless block_given?

        variants.merge!(yield)
      end

      # The variation spec used to generate the AVIF representation of the
      # given variant key (or of the original size when the key is nil).
      def avif_variation_spec(key)
        key && variants[key].present? ? variants[key].merge(format: :avif) : { format: :avif }
      end

      # The variation digest of the AVIF representation. `Blob#variant`
      # normalizes the variation with `default_to` before storing it, which
      # reorders the transformations keys, so the digest must be computed the
      # same way or it would never match the stored VariantRecord.
      def avif_variation_digest(key)
        ActiveStorage::Variation.wrap(avif_variation_spec(key)).default_to(format: :png).digest
      end

      # The variation digest of the full-size PNG fallback generated for AVIF
      # originals.
      def fallback_variation_digest
        ActiveStorage::Variation.wrap(format: :png).default_to(format: :png).digest
      end
      #
      # # Returns the [blob_id, variation_digest] pairs of the given blobs and
      # # variant keys whose AVIF variant has already been processed, so that
      # # lists of attachments can be checked with a single query.
      # def processed_avif_variant_records(blobs, keys)
      #   blobs = Array(blobs).compact
      #   return [] if blobs.empty?
      #
      #   blob_ids = blobs.map(&:id)
      #   digests = Array(keys).map { |key| avif_variation_digest(key) }.uniq
      #
      #   ActiveStorage::VariantRecord.where(blob_id: blob_ids, variation_digest: digests)
      #                               .pluck(:blob_id, :variation_digest)
      # end
    end
  end
end
