# frozen_string_literal: true

class AddAttachmentsCountToDecidimDebatesDebates < ActiveRecord::Migration[8.1]
  def change
    add_column :decidim_debates_debates, :attachments_count, :integer, default: 0, null: false
  end
end
