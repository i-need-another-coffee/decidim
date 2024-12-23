# frozen_string_literal: true

class AddFollowableCounterCacheToConferences < ActiveRecord::Migration[5.2]
  class Conference < ApplicationRecord
    self.table_name = :decidim_conferences
    include Decidim::Followable

  end

  def change
    add_column :decidim_conferences, :follows_count, :integer, null: false, default: 0, index: true

    reversible do |dir|
      dir.up do
        Conference.reset_column_information
        Conference.unscoped.find_each do |record|
          record.class.reset_counters(record.id, :follows)
        end
      end
    end
  end
end
