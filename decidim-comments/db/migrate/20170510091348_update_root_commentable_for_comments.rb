# frozen_string_literal: true

class UpdateRootCommentableForComments < ActiveRecord::Migration[5.0]
  class Comment < ApplicationRecord
    self.table_name = :decidim_comments_comments

    include Decidim::Comments::Commentable
  end
  def up
    # rubocop:disable Rails/SkipsModelValidations
    Comment.where(depth: 0).update_all(
      "decidim_root_commentable_id = decidim_commentable_id, decidim_root_commentable_type = decidim_commentable_type"
    )
    # rubocop:enable Rails/SkipsModelValidations

    Comment.where("depth > 0").find_each do |comment|
      comment.root_commentable = root_commentable(comment)
      comment.save(validate: false)
    end
  end

  def down; end

  private

  def root_commentable(comment)
    return comment.commentable if comment.depth.zero?

    root_commentable comment.commentable
  end
end
