# frozen_string_literal: true

class AddAttachmentsCountToDecidimConferences < ActiveRecord::Migration[8.1]
  def up
    ids = Decidim::Conference.unscoped.pluck(:id)
    ids.each { |id| Decidim::Conference.unscoped.reset_counters(id, :attachments_count) }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
