# frozen_string_literal: true

require "spec_helper"

describe Decidim::Api::GraphqlPermissions do
  let(:organization) { create(:organization) }
  let(:admin) { create(:user, :admin, :confirmed, organization:, admin_terms_accepted_at: 1.day.ago) }
  let(:regular_user) { create(:user, :confirmed, organization:) }
  let(:attachment) { create(:attachment, attached_to: organization) }

  # A type that only requires the API read scope, so the scope derived from the
  # required scopes is the public one. The attachment is only allowed through the
  # admin permission class, which only applies in the admin scope.
  let(:type_class) do
    Class.new(Decidim::Api::Types::BaseObject) do
      required_scopes "api:read"
    end
  end

  def allowed(context)
    type_class.allowed_to?(:read, :attachment, attachment, context)
  end

  context "when the context defines the scope" do
    it "checks the permission with the scope from the context" do
      expect(allowed({ current_user: admin, scope: :admin })).to be true
    end

    it "denies a user that the scope does not grant" do
      expect(allowed({ current_user: regular_user, scope: :admin })).to be false
    end
  end

  context "when the context does not define the scope" do
    it "falls back to the scope derived from the required scopes" do
      expect(allowed({ current_user: admin })).to be false
    end
  end
end
