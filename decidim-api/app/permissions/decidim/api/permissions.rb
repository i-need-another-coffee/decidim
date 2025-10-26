# frozen_string_literal: true

module Decidim
  module Api
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless user

        allow! if subject == :tokens

        permission_action
      end
    end
  end
end
