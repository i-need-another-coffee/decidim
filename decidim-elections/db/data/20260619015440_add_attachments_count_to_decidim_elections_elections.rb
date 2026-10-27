# frozen_string_literal: true

class AddAttachmentsCountToDecidimElectionsElections < ActiveRecord::Migration[8.1]
  def up
    ids = ::Decidim::Elections::Election.unscoped.pluck(:id)
    ids.each { |id| ::Decidim::Elections::Election.unscoped.reset_counters(id, :attachments_count) }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
