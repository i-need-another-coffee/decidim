# frozen_string_literal: true

class AddAttachmentsCountToDecidimDebatesDebates < ActiveRecord::Migration[8.1]
  def up
    ids = Decidim::Debates::Debate.unscoped.pluck(:id)
    ids.each { |id| Decidim::Debates::Debate.unscoped.reset_counters(id, :attachments_count) }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
