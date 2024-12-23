# frozen_string_literal: true

class AddFollowableCounterCacheToDebates < ActiveRecord::Migration[5.2]
  class Debate < ApplicationRecord
    self.table_name = :decidim_debates_debates
    include Decidim::HasComponent
    include Decidim::Followable
  end
  def change
    add_column :decidim_debates_debates, :follows_count, :integer, null: false, default: 0, index: true

    reversible do |dir|
      dir.up do
        Debate.reset_column_information
        Debate.unscoped.find_each do |record|
          record.class.reset_counters(record.id, :follows)
        end
      end
    end
  end
end
