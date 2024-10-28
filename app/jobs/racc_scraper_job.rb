class RaccScraperJob < ApplicationJob
  queue_as :default

  def perform(*args)
    RaccScraper.new.scrape
  end
end
