# frozen_string_literal: true

namespace :decidim do
  desc "Performs upgrade tasks (migrations, node, docs )."
  task upgrade: [
    :choose_target_plugins,
    :framework_defaults,
    :upgrade_app,
    :"railties:install:migrations",
    :"decidim:upgrade:migrations",
    :"decidim:upgrade:webpacker",
    :"decidim_api:generate_docs"
  ]

  task update: [:upgrade]

  desc "Sets up environment so that only decidim migrations are installed."
  task :choose_target_plugins do
    ENV["FROM"] = %w(
      decidim
      decidim_accountability
      decidim_admin
      decidim_assemblies
      decidim_blogs
      decidim_budgets
      decidim_collaborative_texts
      decidim_comments
      decidim_conferences
      decidim_debates
      decidim_elections
      decidim_forms
      decidim_initiatives
      decidim_meetings
      decidim_pages
      decidim_participatory_processes
      decidim_proposals
      decidim_sortitions
      decidim_surveys
      decidim_system
      decidim_templates
      decidim_verifications
    ).join(",")
  end

  desc "Applies upgrade modifications to the already installed application."
  task upgrade_app: [:"decidim:remove_default_favicon"]

  desc "Removes the default favicon from the application."
  task :remove_default_favicon do
    FileUtils.rm("public/favicon.ico", force: true)
  end

  task framework_defaults: :environment do
    copy_file_from_core_to_application("config/initializers/new_framework_defaults_7_0.rb", "config/initializers/new_framework_defaults_7_0.rb")
  end

  private

  def copy_file_from_core_to_application(origin_path, destination_path = origin_path, force: false)
    return if File.exist?(rails_app_path.join(destination_path)) && !force

    FileUtils.cp(decidim_core_path.join(origin_path), rails_app_path.join(destination_path), verbose: true)
  end

  def decidim_core_path
    Pathname.new(Gem.loaded_specs["decidim-core"].full_gem_path)
  end

  def rails_app_path
    @rails_app_path ||= Rails.root
  end
end
