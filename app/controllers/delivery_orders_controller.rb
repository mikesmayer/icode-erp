class DeliveryOrdersController < ApplicationController
  before_filter :check_validate_of_period_in_ste, :only => [:new, :update]
  layout "sheetbox", :only => [:show, :new, :create, :edit, :update]
  
  def index
    @search = DeliveryOrder.search(params[:search])
    @delivery_orders = DeliveryOrder.search_do(@search)
    @delivery_orders = @delivery_orders.paginate(:page => params[:page])
  end

  def kiv
    @search = DeliveryOrder.search(params[:search])
    @delivery_orders = DeliveryOrder.search_do_kiv(@search)
    @delivery_orders = @delivery_orders.paginate(:page => params[:page])
  end
  
  def show_trade_company_name
    @delivery_order = DeliveryOrder.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @delivery_order }
    end
  end
  
  def new
    @delivery_order = DeliveryOrder.new
    @sales_order = SalesOrder.so_pid_desc
  end

  def edit
    @delivery_order = DeliveryOrder.find(params[:id])
    @sales_order = SalesOrder.so_pid_desc
  end

  def create
    @delivery_order = DeliveryOrder.new(params[:delivery_order])
    check_delivery_order, msg = DeliveryOrderManagement.running_delivery_order_items(params[:datarow], @delivery_order)
    if check_delivery_order.present? && @delivery_order.save
      company.update_attributes(:sn_deliver_order_no => @delivery_order.do_no)
      DeliveryOrderManagement.manage_inventory_and_product(@delivery_order)
      redirect_to @delivery_order, notice: 'Delivery Order was successfully created.'
    else
      msg.present? ? msg : msg = []
      msg << @delivery_order.errors.full_messages
      flash[:alert] = msg.join(', ')
      render action: "new"
    end
  end

  def update
    @delivery_order = DeliveryOrder.find(params[:id])
    respond_to do |format|
      if @delivery_order.update_attributes(params[:delivery_order])
        format.html { redirect_to @delivery_order, notice: 'Delivery order was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @delivery_order.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @delivery_order = DeliveryOrder.find(params[:id])
    @delivery_order.update_attributes(:status => DeliveryOrder::KEEP_IN_VIEW)
    redirect_to delivery_orders_url, :notice => "Delivery Order No # #{@delivery_order.do_no} has dropped to KIV."
  end
  
  def recover
    @delivery_order = DeliveryOrder.find(params[:id])
    @delivery_order.update_attributes(:status => DeliveryOrder::ACTIVE)
    redirect_to kiv_delivery_orders_url, :notice => "Delivery Order No # #{@delivery_order.do_no} has recovered."
  end
  
  def load_data_to_outgoing_reject
    @delivery_order = DeliveryOrder.find_by_do_no_and_trade_company_id(params[:do_no], params[:company_id])
    @delivery_order_json = @delivery_order.manage_outgoing_reject
    render json: @delivery_order_json, :root => false
  end
end
