# frozen_string_literal: true

class AddAttachmentsCountToDecidimMeetingsMeetings < ActiveRecord::Migration[8.1]
  def up
    ids = ::Decidim::Meetings::Meeting.unscoped.pluck(:id)
    ids.each { |id| ::Decidim::Meetings::Meeting.unscoped.reset_counters(id, :attachments_count) }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
