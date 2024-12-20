# frozen_string_literal: true

class FixUserGroupsIdsInComments < ActiveRecord::Migration[5.2]
  class UserGroup < ApplicationRecord
    self.table_name = :decidim_user_groups
  end
  class Comment < ApplicationRecord
    self.table_name = :decidim_comments_comments

    include Decidim::Comments::Commentable
  end
  # rubocop:disable Rails/SkipsModelValidations
  def change
    UserGroup.find_each do |group|
      old_id = group.extended_data["old_user_group_id"]
      next unless old_id

      Comment
        .where(decidim_user_group_id: old_id)
        .update_all(decidim_user_group_id: group.id)
    end
  end
  # rubocop:enable Rails/SkipsModelValidations
end
