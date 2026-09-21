# frozen_string_literal: true

Rails.application.config.active_storage[:variable_content_types] << "image/webp"
Rails.application.config.active_storage[:web_image_content_types] << "image/avif"
Rails.application.config.active_storage[:track_variants] = true
