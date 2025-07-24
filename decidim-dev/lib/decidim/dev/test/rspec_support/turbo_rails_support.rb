# frozen_string_literal: true

module TurboRailsSupport
  def wait_for_turbo
    page.evaluate_script('new Promise(resolve => { document.addEventListener("turbo:load", () => resolve(true), { once: true }); })')
  end
end

RSpec.configure do |config|
  config.include TurboRailsSupport, type: :system
end
