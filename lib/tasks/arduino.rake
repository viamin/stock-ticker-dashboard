namespace :arduino do
  desc "Update Arduino ticker"
  task update_ticker: :environment do
    newest_manipulation = Manipulation.order(created_at: :desc).limit(1).first
    unless newest_manipulation.created_at > 6.minutes.ago
      Arduino.new.update!
    end
  end
end
