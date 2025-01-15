Rails.application.routes.draw do
  mount Decidim::TranslationAddons::Engine => "/decidim-translation_addons"
end
