namespace :categories do
  desc "Import categories from the stocks csv"
  task import: :environment do
    require "csv"

    csv_text = File.read(Rails.root.join("vendor", "stocks.csv"))
    csv = CSV.parse(csv_text, headers: true, encoding: "utf-8")
    csv.each do |row|
      stock = Stock.find_by(ticker: row["Ticker"])
      if stock
        stock.update!(category: row["Category"])
      else
        puts "Stock not found: #{row['Ticker']}"
      end
    end
  end
end
