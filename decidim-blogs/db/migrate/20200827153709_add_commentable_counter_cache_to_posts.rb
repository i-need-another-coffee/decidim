# frozen_string_literal: true

class AddCommentableCounterCacheToPosts < ActiveRecord::Migration[5.2]
  class Post < ApplicationRecord
    self.table_name = :decidim_blogs_posts

    include Decidim::HasComponent
    include Decidim::Comments::CommentableWithComponent
  end

  def change
    add_column :decidim_blogs_posts, :comments_count, :integer, null: false, default: 0, index: true
    Post.reset_column_information
    Post.unscoped.find_each(&:update_comments_count)
  end
end
