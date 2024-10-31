namespace :racc do
  desc "Scrape RaccCity data"
  task scrape: :environment do
    RaccCity.new.scrape
  end
end
