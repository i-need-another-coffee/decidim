# frozen_string_literal: true

class AddBadges < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_gamification_badges do |t|
      t.integer :decidim_organization_id, null: false, index: true
      t.jsonb :name, null: false, default: {}
      t.jsonb :description, null: false, default: {}
      t.string :manifest_name, null: false, index: true
      t.jsonb :settings, default: {}
      t.datetime :published_at, index: true
      t.integer :weight
    end

    add_index(
      :decidim_gamification_badges,
      [:decidim_organization_id, :manifest_name],
      unique: true,
      name: "idx_uniq_org_id_manifest_name"
    )
  end
end
