# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents a attachable object.
    module ResourceableInterface
      include Decidim::Api::Types::BaseInterface
      description "An interface that can be used in display resource methods"
    end
  end
end
