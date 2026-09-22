# frozen_string_literal: true

class AddAttachmentsCountToDecidimMeetingsMeetings < ActiveRecord::Migration[8.1]
  def change
    add_column :decidim_meetings_meetings, :attachments_count, :integer, default: 0, null: false
  end
end
