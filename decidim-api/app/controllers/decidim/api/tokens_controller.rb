# frozen_string_literal: true

module Decidim
  module Api
    class TokensController < Decidim::ApplicationController
      register_permissions(::Decidim::Api::TokensController,
                           ::Decidim::Api::Permissions,
                           ::Decidim::Permissions)

      def permission_class_chain
        ::Decidim.permissions_registry.chain_for(::Decidim::Api::TokensController)
      end

      include Decidim::UserProfile

      def index
        enforce_permission_to(:read, :tokens, current_user:)
      end

      def new
        enforce_permission_to(:create, :tokens, current_user:)
        @form = form(TokenForm).instance
      end

      def create
        enforce_permission_to(:create, :tokens, current_user:)
      end

    end
  end
end
