# frozen_string_literal: true

class AddAttachmentsCountToDecidimInitiatives < ActiveRecord::Migration[8.1]
  def change
    add_column :decidim_initiatives, :attachments_count, :integer, default: 0, null: false
  end
end
