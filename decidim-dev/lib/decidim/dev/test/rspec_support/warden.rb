# frozen_string_literal: true

module Decidim
  module WardenTestHelpers
    include Warden::Test::Helpers

    #
    # Utility method to login in the middle of a test as a different user from
    # the current one.
    #
    def relogin_as(user, scope: :user, url: nil)
      logout scope
      clear_session!
      sleep 0.5

      visit url.nil? ? current_url : url

      login_as(user, scope:)
      visit url.nil? ? current_url : url
    end

    def clear_session!
      ActiveRecord::SessionStore::Session.delete_all
      ActiveRecord::Base.connection.clear_query_cache
      page.driver.browser.manage.delete_all_cookies if page.driver.respond_to?(:browser) && page.driver.browser.respond_to?(:manage)
    end
  end
end

RSpec.configure do |config|
  config.include Decidim::WardenTestHelpers, type: :system
  config.include Decidim::WardenTestHelpers, type: :request
  config.include Devise::Test::ControllerHelpers, type: :controller

  config.before :each, type: :cell do
    if controller
      allow(controller).to receive(:current_organization).and_return(try(:organization) || try(:current_organization) || nil)
      allow(controller).to receive(:current_user).and_return(try(:user) || try(:current_user) || nil)
    end
  end

  config.before :each, type: :system do
    Warden::Manager.after_set_user do |_user, auth, _opts|
      auth.env["rack.session.options"][:renew] = false
    end
  end

  config.after :each, type: :system do
    Warden.test_reset!
  end

  config.after :each, type: :request do
    Warden.test_reset!
  end
end
