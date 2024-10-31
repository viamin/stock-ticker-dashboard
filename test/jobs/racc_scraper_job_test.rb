require "test_helper"
require "minitest/mock"

class RaccScraperJobTest < ActiveJob::TestCase
  test "job is enqueued with correct queue" do
    assert_equal "default", RaccScraperJob.queue_as.to_s
  end

  test "performs scraping" do
    mock_scraper = Object.new
    def mock_scraper.scrape; end # Define a scrape method that does nothing

    RaccCity.stub :new, mock_scraper do
      # Assert no errors are raised
      assert_nothing_raised do
        RaccScraperJob.perform_now
      end
    end
  end

  test "enqueues job" do
    assert_enqueued_with(job: RaccScraperJob) do
      RaccScraperJob.perform_later
    end
  end

  test "job can be enqueued multiple times" do
    assert_enqueued_jobs 0
    3.times { RaccScraperJob.perform_later }
    assert_enqueued_jobs 3
  end

  test "job handles scraper errors" do
    mock_scraper = Object.new
    def mock_scraper.scrape
      raise StandardError, "Scraping failed"
    end

    RaccCity.stub :new, mock_scraper do
      assert_raises StandardError do
        RaccScraperJob.perform_now
      end
    end
  end
end
