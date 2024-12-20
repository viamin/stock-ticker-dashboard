class ManipulationsController < ApplicationController
  def index
  end

  def new
    @stocks = Stock.active
    @manipulation = Manipulation.new
  end

  def create
    @stocks = Stock.active
    @manipulation = Manipulation.new(manipulation_params)

    if @manipulation.save
      RaccManipulatorJob.perform_later(@manipulation.id)
      TickerUploadJob.perform_later(@manipulation.id)
      # Arduino.new(insider_text: @manipulation.message, manipulation: true).update!
      # RaccCity.new.manipulate(@manipulation)
      TickerUploadJob.perform_in(3.minutes) # leave off manipulation to only have ticker text (no manipulations)
      redirect_to root_path
    else
      render :new
    end
  end

  def show
  end

  private

  def manipulation_params
    params.require(:manipulation).permit(:category, :message, :action, :newvalue, :racc_username)
  end
end
