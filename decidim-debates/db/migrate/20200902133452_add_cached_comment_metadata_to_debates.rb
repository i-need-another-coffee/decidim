# frozen_string_literal: true

class AddCachedCommentMetadataToDebates < ActiveRecord::Migration[5.2]
  class Debate < ApplicationRecord
    self.table_name = :decidim_debates_debates
    include Decidim::HasComponent
    include Decidim::Comments::CommentableWithComponent
  end

  def change
    add_column :decidim_debates_debates, :last_comment_at, :datetime
    add_column :decidim_debates_debates, :last_comment_by_id, :integer
    add_column :decidim_debates_debates, :last_comment_by_type, :string

    # rubocop:disable Rails/SkipsModelValidations
    Debate.reset_column_information
    Debate.unscoped.includes(comments: [:author, :user_group]).find_each do |debate|
      last_comment = debate.comments.order("created_at DESC").first
      next unless last_comment

      debate.update_columns(
        last_comment_at: last_comment.created_at,
        last_comment_by_id: last_comment.decidim_author_id,
        last_comment_by_type: last_comment.decidim_author_type
      )
    end
    # rubocop:enable Rails/SkipsModelValidations
  end
end
