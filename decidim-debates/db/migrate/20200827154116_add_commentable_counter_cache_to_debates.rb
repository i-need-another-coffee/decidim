# frozen_string_literal: true

class AddCommentableCounterCacheToDebates < ActiveRecord::Migration[5.2]
  class Debate < ApplicationRecord
    self.table_name = :decidim_debates_debates
    include Decidim::HasComponent
    include Decidim::Comments::CommentableWithComponent
  end

  def change
    add_column :decidim_debates_debates, :comments_count, :integer, null: false, default: 0, index: true
    Debate.reset_column_information

    # rubocop:disable Rails/SkipsModelValidations
    Debate.unscoped.includes(:comments).find_each do |debate|
      debate.update_columns(comments_count: debate.comments.not_hidden.count)
    end
    # rubocop:enable Rails/SkipsModelValidations
  end
end
