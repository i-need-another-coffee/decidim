# frozen_string_literal: true

require "spec_helper"

describe "Organizations" do
  let(:admin) { create(:admin) }
  let!(:organization) { create(:organization) }

  context "when an admin authenticated" do
    before do
      login_as admin, scope: :admin
      visit decidim_system.root_path
      click_on "Organizations"
      click_on "Delete"
      accept_confirm
    end

    it "deletes an organization" do
      expect(page).to have_content("Destroy Organization")
      expect(page).to have_content("The following action is irreversible.")
      expect(page).to have_content("Type in \"#{organization.host}\" to confirm the organization deletion.")
      fill_in "Confirmation", with: organization.host
      click_on "Delete this organization"
      expect(page).to have_content("Organization successfully deleted.")

      expect(organization.reload).to be_deleted
    end

    it "cancels the deletion" do
      expect(page).to have_content("Destroy Organization")
      expect(page).to have_content("The following action is irreversible.")
      expect(page).to have_content("Type in \"#{organization.host}\" to confirm the organization deletion.")
      fill_in "Confirmation", with: organization.host
      click_on "Cancel"

      expect(organization.reload).not_to be_deleted
    end

    it "does not delete an organization without confirmation" do
      expect(page).to have_content("Destroy Organization")
      expect(page).to have_content("The following action is irreversible.")
      expect(page).to have_content("Type in \"#{organization.host}\" to confirm the organization deletion.")
      fill_in "Confirmation", with: "I don't understand"
      click_on "Delete this organization"

      expect(page).to have_content("There was a problem deleting this organization.")
    end
  end
end
