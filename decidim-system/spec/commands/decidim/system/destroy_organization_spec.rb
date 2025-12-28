# frozen_string_literal: true

require "spec_helper"

module Decidim::System
  describe DestroyOrganization do
    let(:form) do
      DestroyOrganizationForm.new(params).with_context(current_organization: organization)
    end
    let!(:organization) { create(:organization, name: { en: "My organization" }) }

    let(:command) { described_class.new(organization.id, form) }

    context "when the form is valid" do
      let(:params) { { confirmation: organization.host } }

      it "returns an invalid response" do
        clear_enqueued_jobs
        expect(Decidim::Organization.count).to eq(1)
        expect { command.call }.to broadcast(:ok)
        expect(Decidim::Organization.count).to eq(0)
        expect(organization.reload).to be_deleted
        expect(Decidim::DestroyOrganizationJob).to have_been_enqueued.with(organization.id)
      end
    end

    context "when the form is invalid" do
      context "when the confirmation does not match" do
        let(:params) { { confirmation: "Foo bar" } }

        it "returns an invalid response" do
          expect { command.call }.to broadcast(:invalid)
        end
      end

      context "when the confirmation is empty" do
        let(:params) { { confirmation: "" } }

        it "returns an invalid response" do
          expect { command.call }.to broadcast(:invalid)
        end
      end
    end
  end
end
