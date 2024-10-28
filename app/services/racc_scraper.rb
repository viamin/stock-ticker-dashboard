class RaccScraper
  attr_reader :client

  def initialize
    @client = Faraday.new(url: Rails.application.credentials.racc_scraper[:host])
  end

  def scrape
    endpoint = Rails.application.credentials.racc_scraper[:endpoint]
    response = client.get(endpoint)
    doc = JSON.parse(response.body)
    doc.each do |stock_json|
      stock = Stock.find_or_create_by(ticker: stock_json["symbol"], name: stock_json["companyname"])
      stock.prices.create(cents: (stock_json["latestprice"] * 100).to_i, date: Time.current)
    end
  end
end
