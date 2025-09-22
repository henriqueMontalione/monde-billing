class CustomersController < ApplicationController
  before_action :set_customer, only: [:show, :edit, :update, :destroy]

  def index
    @customers = Customer.order(:name).page(params[:page])

    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def show
  end

  def new
    @customer = Customer.new

    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  def create
    @customer = Customer.new(customer_params)

    respond_to do |format|
      if @customer.save
        format.turbo_stream
        format.html { redirect_to @customer, notice: 'Cliente criado com sucesso.' }
      else
        format.turbo_stream { render :new, status: :unprocessable_entity }
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if @customer.update(customer_params)
        format.turbo_stream
        format.html { redirect_to @customer, notice: 'Cliente atualizado com sucesso.' }
      else
        format.turbo_stream { render :edit, status: :unprocessable_entity }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @customer.destroy

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to customers_url, notice: 'Cliente removido com sucesso.', status: :see_other }
    end
  end

  private

  def set_customer
    @customer = Customer.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(:name, :email, :billing_day, :payment_method_type)
  end
end
