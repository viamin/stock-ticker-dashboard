class RaccScraper
  attr_reader :client

  def initialize
    @client = Faraday.new(url: Rails.application.credentials.racc_scraper[:host])
  end

  def scrape
    endpoint = Rails.application.credentials.racc_scraper[:endpoint]
    response = client.get(endpoint)
    doc = JSON.parse(response.body)
    # TODO: update stocks and prices - need schema
  end
end
