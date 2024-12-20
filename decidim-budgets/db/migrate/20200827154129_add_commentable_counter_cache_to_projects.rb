# frozen_string_literal: true

class AddCommentableCounterCacheToProjects < ActiveRecord::Migration[5.2]
  class Project < ApplicationRecord
    self.table_name = :decidim_budgets_projects

    include Decidim::HasComponent
    include Decidim::Comments::CommentableWithComponent
  end


  def change
    add_column :decidim_budgets_projects, :comments_count, :integer, null: false, default: 0, index: true
    Project.reset_column_information
    Project.unscoped.find_each(&:update_comments_count)
  end
end
