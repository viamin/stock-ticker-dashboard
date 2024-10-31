class RaccScraperJob < ApplicationJob
  queue_as :default

  def perform(*args)
    RaccCity.new.scrape
  end
end
