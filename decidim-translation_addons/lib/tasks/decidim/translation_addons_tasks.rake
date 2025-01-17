# desc "Explaining what the task does"
# task :decidim_translation_addons do
#   # Task goes here
# end

namespace :decidim do
  namespace :translation_addons do
    # task upgrade: [:choose_target_plugins, :"railties:install:migrations"]

    task :choose_target_plugins do
      ENV["FROM"] = "#{ENV.fetch("FROM", nil)},decidim_translation_addons"
    end

    desc "Searches for missing translations"
    task :search_missing_translations do
      puts "Not implemented"
      # Get organizations - Decidim::Organization => Enumerable
      #
      # for each organization get available_locales
      #
      # Get all Resources classes that implement TranslatableResource
      #
      # for each resource class get translatable fields
      #
      # Get items of the current resource and for each
      #
      # for each field, check if it has all the keys as available_locales
      #
      # if a locale is missing create a Decidim::TranslationAddons::Report
    end
  end
end

Rake::Task["decidim:choose_target_plugins"].enhance do
  Rake::Task["decidim:translation_addons:choose_target_plugins"].invoke
end
