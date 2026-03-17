# frozen_string_literal: true

class AddDeletedAtToDecidimOrganizations < ActiveRecord::Migration[7.0]
  def change
    add_column :decidim_organizations, :deleted_at, :datetime
    add_index :decidim_organizations, :deleted_at
  end
end
