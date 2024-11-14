namespace :arduino do
  desc "Update Arduino ticker"
  task update_ticker: :environment do
    Arduino.new.update!
  end
end
