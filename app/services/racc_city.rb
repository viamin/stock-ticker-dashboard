class RaccCity
  attr_reader :client

  def initialize
    @client = Faraday.new(url: Rails.application.credentials.racc_scraper[:endpoint])
  end

  def scrape
    response = client.get
    doc = parse_json(response.body)
    doc.each do |stock_json|
      Stock.find_or_create_by!(ticker: stock_json["symbol"], name: stock_json["companyname"])
      stock = Stock.find_by(ticker: stock_json["symbol"], name: stock_json["companyname"])
      stock.prices.create(cents: (stock_json["latestprice"] * 100).to_i, date: Time.current)
    end
  end

  def parse_json(json)
    begin
      # Try to parse it once
      parsed = JSON.parse(json)
      # If the result is still a string, try parsing again
      parsed = JSON.parse(parsed) if parsed.is_a?(String)
      parsed
    rescue JSON::ParserError
      # Handle parsing errors
      Rails.logger.error "Failed to parse JSON response: #{json}"
      nil
    end
  end
end
