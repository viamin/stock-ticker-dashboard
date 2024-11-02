class TickerUploadJob < ApplicationJob
  queue_as :default

  def perform(manipulation_id = nil)
    manipulation = Manipulation.find_by(id: manipulation_id)
    if manipulation
      Arduino.new(insider_text: manipulation.message, manipulation: true).update!
    else
      Arduino.new.update!
    end
  end
end
