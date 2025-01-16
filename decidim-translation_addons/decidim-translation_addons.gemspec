require_relative "lib/decidim/translation_addons/version"

Gem::Specification.new do |spec|
  spec.name = "decidim-translation_addons"
  spec.version = Decidim::TranslationAddons::VERSION
  spec.authors = ["robert"]
  spec.email = ["robert.luca@publicissapient.com"]
  spec.homepage = "https://decidim.org"
  spec.summary = "Summary of Decidim::TranslationAddons."
  spec.description = "Description of Decidim::TranslationAddons."
  spec.license = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/decidim/decidim"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").select do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w(app/ config/ db/ lib/ Rakefile README.md))
    end
  end

  spec.add_dependency "deface"
  spec.add_dependency "rails", ">= 7.0.8.4"
end
