# frozen_string_literal: true

class CreateDecidimTranslationReports < ActiveRecord::Migration[7.0]
  def change
    create_table :decidim_translation_reports do |t|
      t.references :decidim_user, null: false
      t.references :decidim_resource, polymorphic: true, index: false, null: false
      t.string :field_name
      t.string :locale
      t.string :reason
      t.string :fix_suggestion
      t.integer :auto_translation_failed_count, default: 0
      t.datetime :deleted_at, index: true
      t.timestamps
    end
    add_index :decidim_translation_reports, [:decidim_resource_type, :decidim_resource_id], name: "index_decidim_translation_reports_on_resource"
  end
end
