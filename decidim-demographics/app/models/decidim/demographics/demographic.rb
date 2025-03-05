# frozen_string_literal: true

module Decidim
  module Demographics
    class Demographic < ApplicationRecord
      belongs_to :decidim_user, foreign_key: :decidim_user_id, class_name: "Decidim::User"
    end
  end
end
