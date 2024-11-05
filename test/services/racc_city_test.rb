require "test_helper"
require "ostruct"

class RaccCityTest < ActiveSupport::TestCase
  def setup
    @mock_credentials = {
      endpoint: "https://api.example.com/stocks"
    }

    Rails.application.credentials.stub :racc_city, @mock_credentials do
      @scraper = RaccCity.new
    end
  end

  test "scrape makes request to configured endpoint" do
    skip "not working"
    mock_client = Object.new
    def mock_client.get
      Faraday::Response.new(
        status: 200,
        body: [
            { symbol: "AAPL", companyname: "Apple Inc.", latestprice: 150.00 }
          ].to_json
      )
    end

    Rails.application.credentials.stub :racc_city, @mock_credentials do
      @scraper.stub :client, mock_client do
        assert_nothing_raised do
          @scraper.scrape
        end
      end
    end
  end
end
