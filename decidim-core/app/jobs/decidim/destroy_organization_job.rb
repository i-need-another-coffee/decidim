# frozen_string_literal: true

module Decidim
  class DestroyOrganizationJob < ApplicationJob
    queue_as :default
    def perform(organization_id); end
  end
end
