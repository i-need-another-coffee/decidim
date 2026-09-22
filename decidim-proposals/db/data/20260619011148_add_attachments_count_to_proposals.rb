# frozen_string_literal: true

class AddAttachmentsCountToProposals < ActiveRecord::Migration[8.1]
  def up
    ids = Decidim::Proposals::Proposal.unscoped.pluck(:id)
    ids.each { |id| Decidim::Proposals::Proposal.unscoped.reset_counters(id, :attachments_count) }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
