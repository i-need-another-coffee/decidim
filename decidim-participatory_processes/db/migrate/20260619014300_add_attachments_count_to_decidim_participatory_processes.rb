# frozen_string_literal: true

class AddAttachmentsCountToDecidimParticipatoryProcesses < ActiveRecord::Migration[8.1]
  def change
    add_column :decidim_participatory_processes, :attachments_count, :integer, default: 0, null: false
  end
end
