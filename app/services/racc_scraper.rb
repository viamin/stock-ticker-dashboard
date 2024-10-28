class RaccScraper
  attr_reader :client

  def initialize
    @client = Faraday.new(url: ENV.fetch("RACC_SCRAPER_HOST"))
  end

  def scrape
    endpoint = ENV.fetch("RACC_SCRAPER_ENDPOINT")
    response = client.get(endpoint)
    doc = JSON.parse(response.body)
    # TODO: update stocks and prices - need schema
  end
end
