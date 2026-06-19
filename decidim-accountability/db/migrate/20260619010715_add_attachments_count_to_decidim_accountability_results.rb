# frozen_string_literal: true

class AddAttachmentsCountToDecidimAccountabilityResults < ActiveRecord::Migration[8.1]
  def change
    add_column :decidim_accountability_results, :attachments_count, :integer, default: 0, null: false
  end
end
