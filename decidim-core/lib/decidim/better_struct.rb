# frozen_string_literal: true

# This is a simple wrapper over the Rails struct method that helps us have the same old api call as we did with OpenStruct
# The suggestion comes from: https://github.com/rubocop/rubocop/issues/10206#issuecomment-1015992128
module Decidim
  class BetterStruct
    def initialize(args = nil)
      @data = if args.is_a?(Hash)
                # Convert string keys to symbols to ensure valid identifiers
                symbol_keys = args.keys.map(&:to_sym)
                Struct.new(*symbol_keys).new(*args.values)
              else
                Struct.new(args)
              end
    end

    attr_reader :data

    delegate :to_h, :dig, :each_pair, to: :data

    def respond_to_missing?(name, include_private)
      data.respond_to?(name.to_sym) || super
    end

    def method_missing(method_name, *_args)
      symbol_method = method_name.to_sym
      data.respond_to?(symbol_method) ? data.send(symbol_method) : nil
    end

    def [](key)
      symbol_key = key.to_sym
      data.respond_to?(symbol_key) ? data.send(symbol_key) : nil
    end
  end
end
