class RaccManipulatorJob < ApplicationJob
  queue_as :default

  def perform(manipulation_id)
    manipulation = Manipulation.find(manipulation_id)
    RaccCity.new.manipulate(manipulation)
  end
end
