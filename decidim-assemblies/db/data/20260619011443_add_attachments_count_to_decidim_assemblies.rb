# frozen_string_literal: true

class AddAttachmentsCountToDecidimAssemblies < ActiveRecord::Migration[8.1]
  def up
    ids = Decidim::Assembly.unscoped.pluck(:id)
    ids.each { |id| Decidim::Assembly.unscoped.reset_counters(id, :attachments_count) }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
