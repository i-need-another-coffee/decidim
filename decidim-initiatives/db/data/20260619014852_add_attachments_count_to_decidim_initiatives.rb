# frozen_string_literal: true

class AddAttachmentsCountToDecidimInitiatives < ActiveRecord::Migration[8.1]
  def up
    ids = ::Decidim::Initiative.unscoped.pluck(:id)
    ids.each { |id| ::Decidim::Initiative.unscoped.reset_counters(id, :attachments_count) }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
