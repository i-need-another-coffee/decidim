# frozen_string_literal: true

class AddAttachmentsCountToDecidimFormsResponses < ActiveRecord::Migration[8.1]
  def up
    ids = ::Decidim::Forms::Response.unscoped.pluck(:id)
    ids.each { |id| ::Decidim::Forms::Response.unscoped.reset_counters(id, :attachments_count) }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
