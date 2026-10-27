# frozen_string_literal: true

class AddAttachmentsCountToDecidimProposalsProposals < ActiveRecord::Migration[8.1]
  def change
    add_column :decidim_proposals_proposals, :attachments_count, :integer, default: 0, null: false
  end
end
