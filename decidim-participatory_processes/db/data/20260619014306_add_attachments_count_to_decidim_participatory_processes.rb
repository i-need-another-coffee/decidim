# frozen_string_literal: true

class AddAttachmentsCountToDecidimParticipatoryProcesses < ActiveRecord::Migration[8.1]
  def up
    ids = ::Decidim::ParticipatoryProcess.unscoped.pluck(:id)
    ids.each { |id| ::Decidim::ParticipatoryProcess.unscoped.reset_counters(id, :attachments_count) }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
