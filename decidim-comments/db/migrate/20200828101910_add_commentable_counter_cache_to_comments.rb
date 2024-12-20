# frozen_string_literal: true

class AddCommentableCounterCacheToComments < ActiveRecord::Migration[5.2]
  class Comment < ApplicationRecord
    self.table_name = :decidim_comments_comments

    include Decidim::Comments::Commentable
  end
  def change
    add_column :decidim_comments_comments, :comments_count, :integer, null: false, default: 0, index: true
    Comment.reset_column_information
    Comment.find_each(&:update_comments_count)
  end
end
