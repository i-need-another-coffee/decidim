# frozen_string_literal: true

require "deface"
require "decidim/translation_addons/version"
require "decidim/translation_addons/engine"

module Decidim
  module TranslationAddons
    include ActiveSupport::Configurable

    config_accessor :reportable_resources do
      %w(
        Decidim::Accountability::Result
        Decidim::Blogs::Post
        Decidim::Comments::Comment
        Decidim::Debates::Debate
        Decidim::Meetings::Meeting
        Decidim::Proposals::Proposal
        Decidim::Assembly
        Decidim::Conference
        Decidim::Initiative
        Decidim::ParticipatoryProcess
      ).select do |klass|
        klass.safe_constantize.present?
      end
    end
  end
end
