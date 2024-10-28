class RaccScraper
  attr_reader :client

  def initialize
    @client = Faraday.new(url: Rails.application.config.racc_scraper_host)
  end

  def scrape
    endpoint = Rails.application.config.racc_scraper_endpoint
    response = client.get(endpoint)
    doc = JSON.parse(response.body)
    # TODO: update stocks and prices - need schema
  end
end
