# frozen_string_literal: true

module Decidim
  module ControllerExampleGroup
    extend ActiveSupport::Concern

    class_methods do
      def routes
        before do
          routes = yield
          @orig_default_url_options = routes.default_url_options.dup
          routes.default_url_options[:script_name] = ""

          self.routes = routes
        end

        after do
          routes.default_url_options = @orig_default_url_options
        end
      end
    end

    def process(action, method: "GET", params: nil, session: nil, body: nil, flash: {}, format: nil, xhr: false, as: nil) # rubocop:disable Metrics/ParameterLists
      params = (params || {}).symbolize_keys

      params.merge!(use_route: request.env["decidim.current_component"]&.mounted_engine) if request.env["decidim.current_component"].present?

      super
    end

    def patch_request(request)
      fake_options = { key: "_decidim_session", id: "test_session_id" }
      fake_session_hash = {}

      allow(request).to receive(:session).and_return(fake_session_hash)
      allow(request).to receive(:session_options).and_return(fake_options)

      allow(fake_session_hash).to receive(:options).and_return(fake_options)
      allow(fake_session_hash).to receive(:enabled?).and_return(true)
      allow(fake_session_hash).to receive(:loaded?).and_return(true)
      allow(fake_session_hash).to receive(:destroy).and_return(true)

      allow(request).to receive(:reset_session) do
        fake_session_hash.clear
      end

      request.env["action_dispatch.request.session_options"] = fake_options
      request.env["rack.session.options"] = fake_options
      request.env["rack.session"] = fake_session_hash
    end
  end
end

RSpec.configure do |config|
  config.include Decidim::ControllerExampleGroup, type: :controller
end
