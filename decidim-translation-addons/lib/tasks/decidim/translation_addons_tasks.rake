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
  end
end

Rake::Task["decidim:choose_target_plugins"].enhance do
  Rake::Task["decidim:translation_addons:choose_target_plugins"].invoke
end
