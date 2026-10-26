# frozen_string_literal: true

module Decidim
  module Budgets
    class ProjectMutationType < Decidim::Api::Types::BaseObject
      description "Project mutations"
      graphql_name "ProjectMutation"

      field :delete, mutation: Decidim::Budgets::DeleteProjectType, description: "Deletes a project"
      field :update, mutation: Decidim::Budgets::UpdateProjectType, description: "Updates a project"
    end
  end
end
