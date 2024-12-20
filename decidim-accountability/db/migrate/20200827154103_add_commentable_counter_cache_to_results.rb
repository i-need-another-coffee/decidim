# frozen_string_literal: true

class AddCommentableCounterCacheToResults < ActiveRecord::Migration[5.2]
  class Result < ApplicationRecord
    self.table_name = :decidim_accountability_results

    include Decidim::HasComponent
    include Decidim::Comments::CommentableWithComponent
  end

  def change
    add_column :decidim_accountability_results, :comments_count, :integer, null: false, default: 0, index: true
    Result.reset_column_information
    Result.unscoped.find_each(&:update_comments_count)
  end
end
