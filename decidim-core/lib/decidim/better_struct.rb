# frozen_string_literal: true

# This is a simple wrapper over the Rails struct method that helps us have the same old api call as we did with OpenStruct
# The suggestion comes from: https://github.com/rubocop/rubocop/issues/10206#issuecomment-1015992128
module Decidim
  class BetterStruct
    def initialize(args = nil)
      @data = if args.is_a?(Hash)
                Struct.new(*(args.keys)).new(*(args.values))
              else
                Struct.new
              end
    end

    attr_reader :data

    def respond_to_missing?(name, include_private)
      data.respond_to?(name) || super
    end

    def method_missing(method_name, *args, &block)
      data.respond_to?(method_name) ? data.send(method_name, args, block) : nil
    end

    delegate :to_h, to: :data
  end
end
