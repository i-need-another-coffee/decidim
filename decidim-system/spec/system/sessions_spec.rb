# frozen_string_literal: true

require "spec_helper"

describe "Sessions" do
  let!(:admin) do
    create(:admin, email: "admin@example.org",
                   password: "decidim123456789",
                   password_confirmation: "decidim123456789")
  end

  around do |example|
    previous_value = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    begin
      example.run
    ensure
      ActionController::Base.allow_forgery_protection = previous_value
    end
  end

  before do
    visit decidim_system.root_path
  end

  context "when using a correct username and password" do
    it "lets you into the system panel" do
      within ".new_admin" do
        fill_in :admin_email, with: "admin@example.org"
        fill_in :admin_password, with: "decidim123456789"
        find("*[type=submit]").click
      end

      expect(page).to have_text("Dashboard")
    end
  end

  context "when using an incorrect username and password" do
    it "does not let you in the admin panel" do
      within ".new_admin" do
        fill_in :admin_email, with: "admin@example.org"
        fill_in :admin_password, with: "forged_password"
        find("*[type=submit]").click
      end

      expect(page).to have_no_text("Dashboard")
    end
  end

  context "when the csrf token is expired" do
    it "displays a retry error message" do
      within ".new_admin" do
        fill_in :admin_email, with: "admin@example.org"
        fill_in :admin_password, with: "decidim123456789"
      end

      page.driver.browser.manage.delete_all_cookies
      expect(page.driver.browser.manage.all_cookies).to be_empty

      within ".new_admin" do
        find("*[type=submit]").click
      end

      expect(page).to have_text("Unable to verify your request. Please retry.")
    end
  end

  context "when using logout" do
    let(:session_cookie_name) { "_session_id" }

    it "removes the session from the session list" do
      visit current_path
      within ".new_admin" do
        fill_in :admin_email, with: "admin@example.org"
        fill_in :admin_password, with: "decidim123456789"
      end

      within ".new_admin" do
        find("*[type=submit]").click
      end

      expect(page).to have_current_path("/system/organizations/new")

      browser_cookies = page.driver.browser.manage.all_cookies
      session_cookie = browser_cookies.find { |c| c[:name] == session_cookie_name }

      expect(session_cookie).not_to be_nil
      captured_cookie_value = session_cookie[:value]

      click_link "Logout"
      expect(page).to have_current_path("/system/admins/sign_in")

      Capybara.using_session("Duplicate session") do
        driven_by :headless_chrome

        visit decidim_system.root_path

        page.driver.browser.manage.add_cookie(name: session_cookie_name, value: captured_cookie_value, path: "/", secure: false, http_only: true)

        visit decidim_system.root_path

        expect(page).to have_current_path("/system/admins/sign_in")
        expect(page).to have_no_text("Dashboard")
        expect(page).to have_text("You need to log in or create an account before continuing.")
      end
    end
  end
end
