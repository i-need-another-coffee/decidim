# frozen_string_literal: true

class AddAttachmentsCountToDecidimAssemblies < ActiveRecord::Migration[8.1]
  def change
    add_column :decidim_assemblies, :attachments_count, :integer, default: 0, null: false
  end
end
