# frozen_string_literal: true

class AddExternalDomainWhitelistToOrganization < ActiveRecord::Migration[5.2]
  class Organization < ApplicationRecord
    self.table_name = :decidim_organizations
  end

  def change
    add_column :decidim_organizations, :external_domain_whitelist, :string, array: true, default: []

    reversible do |direction|
      direction.up do
        # rubocop:disable Rails/SkipsModelValidations
        Organization.update_all("external_domain_whitelist = ARRAY['decidim.org', 'github.com']")
        # rubocop:enable Rails/SkipsModelValidations
      end
    end
  end
end
