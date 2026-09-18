# frozen_string_literal: true

class AddAttachmentsCountToDecidimBudgetsProjects < ActiveRecord::Migration[8.1]
  def up
    ids = Decidim::Budgets::Project.unscoped.pluck(:id)
    ids.each { |id| Decidim::Budgets::Project.unscoped.reset_counters(id, :attachments_count) }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
