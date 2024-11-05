namespace :racc do
  desc "Scrape RaccCity data"
  task scrape: :environment do
    RaccCity.new.scrape
  end

  desc "Purge old prices"
  task purge: :environment do
    RaccCity.new.purge
  end
end
