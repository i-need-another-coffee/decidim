# frozen_string_literal: true

class AddAttachmentsCountToDecidimBlogsPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :decidim_blogs_posts, :attachments_count, :integer, default: 0, null: false
  end
end
