# frozen_string_literal: true

class AddFollowableCounterCacheToBlogs < ActiveRecord::Migration[5.2]
  class Post < ApplicationRecord
    self.table_name = :decidim_blogs_posts

    include Decidim::HasComponent
    include Decidim::Followable
  end
  def change
    add_column :decidim_blogs_posts, :follows_count, :integer, null: false, default: 0, index: true

    reversible do |dir|
      dir.up do
        Post.reset_column_information
        Post.unscoped.find_each do |record|
          record.class.reset_counters(record.id, :follows)
        end
      end
    end
  end
end
