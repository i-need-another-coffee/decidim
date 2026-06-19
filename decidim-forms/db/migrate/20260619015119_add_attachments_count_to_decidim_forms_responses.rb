# frozen_string_literal: true

class AddAttachmentsCountToDecidimFormsResponses < ActiveRecord::Migration[8.1]
  def change
    add_column :decidim_forms_responses, :attachments_count, :integer, default: 0, null: false
  end
end
