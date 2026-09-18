# frozen_string_literal: true

class AddAttachmentsCountToDecidimBlogPosts < ActiveRecord::Migration[8.1]
  def up
    ids = Decidim::Blogs::Post.unscoped.pluck(:id)
    ids.each { |id| Decidim::Blogs::Post.unscoped.reset_counters(id, :attachments_count) }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
