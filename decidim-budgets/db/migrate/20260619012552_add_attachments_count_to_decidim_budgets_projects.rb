# frozen_string_literal: true

class AddAttachmentsCountToDecidimBudgetsProjects < ActiveRecord::Migration[8.1]
  def change
    add_column :decidim_budgets_projects, :attachments_count, :integer, default: 0, null: false
  end
end
