# frozen_string_literal: true

class AddCommentVoteCounterCacheToComments < ActiveRecord::Migration[6.1]
  class CommentVote < ApplicationRecord
    self.table_name = :decidim_comments_comment_votes
  end

  class Comment < ApplicationRecord
    self.table_name = :decidim_comments_comments

    has_many :up_votes, -> { where(weight: 1) }, foreign_key: "decidim_comment_id", class_name: "CommentVote", dependent: :destroy
    has_many :down_votes, -> { where(weight: -1) }, foreign_key: "decidim_comment_id", class_name: "CommentVote", dependent: :destroy
  end

  def change
    add_column :decidim_comments_comments, :up_votes_count, :integer, null: false, default: 0, index: true
    add_column :decidim_comments_comments, :down_votes_count, :integer, null: false, default: 0, index: true

    # We cannot use the reset_counters as up_votes and down_votes are scoped associationws
    reversible do |dir|
      dir.up do
        Comment.reset_column_information
        Comment.find_each do |record|
          # rubocop:disable Rails/SkipsModelValidations
          record.class.update_counters(record.id, up_votes_count: record.up_votes.length)
          record.class.update_counters(record.id, down_votes_count: record.down_votes.length)
          # rubocop:enable Rails/SkipsModelValidations
        end
      end
    end
  end
end
