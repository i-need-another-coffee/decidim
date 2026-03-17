# frozen_string_literal: true

module Decidim
  module System
    class DestroyOrganizationForm < Form
      mimic :organization

      attribute :confirmation, String
      validates :confirmation, comparison: { equal_to: :host }

      delegate :host, to: :current_organization
    end
  end
end
