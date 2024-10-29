namespace :racc_scrape do
  desc "Scrape RACC data"
  task scrape: :environment do
    RaccScraper.new.scrape
  end
end
