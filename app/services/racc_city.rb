class RaccCity
  attr_reader :client

  def scrape
    client = Faraday.new(url: "#{Rails.application.credentials.racc_city[:base_url]}/ticker/#{api_secret}")
    response = client.get
    doc = parse_json(response.body)
    doc.each do |stock_json|
      Stock.find_or_create_by!(ticker: stock_json["symbol"], name: stock_json["companyname"])
      stock = Stock.find_by(ticker: stock_json["symbol"])
      stock.update(active: true)
      stock.prices.create(cents: (stock_json["latestprice"] * 100).to_i, date: Time.current)
    end
    cleanup(doc)
  end

  def cleanup(doc_hash)
    current_tickers = doc_hash.map { |stock_json| stock_json["symbol"] }
    active_stocks = Stock.active.pluck(:ticker)
    inactive_tickers = active_stocks - current_tickers
    Stock.where(ticker: inactive_tickers).update_all(active: false)
  end

  def purge
    Price.where(cents: ..0).delete_all
  end

  def manipulate(manipulation)
    client = Faraday.new(url: "#{Rails.application.credentials.racc_city[:base_url]}/manipulate/#{api_secret}")
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
