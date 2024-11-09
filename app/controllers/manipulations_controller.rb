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
      # RaccManipulatorJob.perform_later(@manipulation.id)
      RaccCity.new.manipulate(@manipulation)
      TickerUploadJob.perform_later(@manipulation.id)
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
