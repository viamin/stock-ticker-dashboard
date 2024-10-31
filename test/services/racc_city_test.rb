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

  # test "initializes with Faraday client" do
  #   Rails.application.credentials.stub :racc_city, @mock_credentials do
  #     scraper = RaccCity.new
  #     assert_instance_of Faraday::Connection, scraper.client
  #     assert_equal @mock_credentials[:endpoint].chomp("/"), scraper.client.url_prefix.to_s.chomp("/")
  #   end
  # end

  test "scrape makes request to configured endpoint" do
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

  test "scrape handles API errors" do
    mock_client = Object.new
    def mock_client.get(*)
      raise Faraday::Error, "API Error"
    end

    Rails.application.credentials.stub :racc_city, @mock_credentials do
      @scraper.stub :client, mock_client do
        assert_raises Faraday::Error do
          @scraper.scrape
        end
      end
    end
  end

  # test "scrape handles JSON parse errors" do
  #   mock_client = Object.new
  #   def mock_client.get(*)
  #     Faraday::Response.new(status: 200, body: "invalid json")
  #   end

  #   Rails.application.credentials.stub :racc_city, @mock_credentials do
  #     @scraper.stub :client, mock_client do
  #       assert_raises JSON::ParserError do
  #         @scraper.scrape
  #       end
  #     end
  #   end
  # end
end
