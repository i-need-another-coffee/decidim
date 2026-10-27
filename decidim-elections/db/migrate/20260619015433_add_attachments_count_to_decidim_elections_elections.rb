# frozen_string_literal: true

class AddAttachmentsCountToDecidimElectionsElections < ActiveRecord::Migration[8.1]
  def change
    add_column :decidim_elections_elections, :attachments_count, :integer, default: 0, null: false
  end
end
