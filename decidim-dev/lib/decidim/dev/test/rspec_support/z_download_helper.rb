# frozen_string_literal: true

module DownloadHelper
  TIMEOUT = 10
  PATH = Rails.root.join("tmp/downloads").freeze

  def downloads(*)
    page.driver.browser.downloads.files
  end

  def download_path
    wait_for_download
    downloads.first["filePath"]
  end

  def wait_for_download
    Timeout.timeout(TIMEOUT) do
      sleep 0.1 until downloaded?
    end
  end

  def downloaded?
    downloads.any?
  end

  def clear_downloads
    FileUtils.rm_f(downloads)
  end
end

RSpec.configure do |config|
  config.include DownloadHelper, download: true
  config.before :each, download: true do
    FileUtils.mkdir_p DownloadHelper::PATH.to_s
    clear_downloads
  end
end
