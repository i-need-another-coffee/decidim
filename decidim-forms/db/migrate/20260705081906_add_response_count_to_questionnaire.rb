class AddResponseCountToQuestionnaire < ActiveRecord::Migration[8.1]
  def change
    add_column :decidim_forms_questionnaires, :responses_count, :integer, default: 0, null: false
  end
end
