class RaccCity
  attr_reader :client

  def initialize
    @client = Faraday.new(url: Rails.application.credentials.racc_city[:base_url])
  end

  def scrape
    client = Faraday.new(url: "#{Rails.application.credentials.racc_city[:base_url]}/ticker/#{api_secret}")
    response = client.get
    doc = parse_json(response.body)
    doc.each do |stock_json|
      Stock.find_or_create_by!(ticker: stock_json["symbol"], name: stock_json["companyname"])
      stock = Stock.find_by(ticker: stock_json["symbol"], name: stock_json["companyname"])
      stock.prices.create(cents: (stock_json["latestprice"] * 100).to_i, date: Time.current)
    end
  end

  def manipulate(manipulation)
    client.post(manipulation_url, manipulation.to_json, "Content-Type" => "application/json")
  end

  private

  def api_secret
    Rails.application.credentials.racc_city[:secret]
  end

  def manipulation_url
    "#{Rails.application.credentials.racc_city[:base_url]}/manipulate/#{api_secret}"
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
