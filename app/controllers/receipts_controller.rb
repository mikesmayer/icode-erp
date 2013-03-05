class ReceiptsController < ApplicationController
  before_filter :authenticate_user!
  layout "sheetbox", :only => [:show, :new, :create, :edit]
  
  def index
    @search = Receipt.search(params[:search])
    @receipts = Receipt.db_active(@search)
  end
  
  def kiv
    @search = Receipt.search(params[:search])
    @receipts = Receipt.db_kiv(@search)
  end

  def show
    @receipt = Receipt.find(params[:id])
  end

  def new
    @receipt = Receipt.new
  end

  def edit
    @receipt = Receipt.find(params[:id])
  end

  def create
    @receipt = Receipt.new(params[:receipt])
    AccountManagement.manage_receipts(params[:datarow], @receipt)
    if @receipt.save
      company.update_attributes(:sn_receipt_no => @receipt.receipt_no)
      redirect_to @receipt, notice: "Receipt No # #{@receipt.receipt_no} was successfully created."
    else
      flash[:alert] = @receipt.errors.full_messages.join(", ")
      render action: "new"
    end
  end

  def update
    @receipt = Receipt.find(params[:id])
    AccountManagement.manage_receipts(params[:datarow], @receipt)
    if @receipt.update_attributes(params[:receipt])
      redirect_to @receipt, notice: "Receipt No # #{@receipt.receipt_no} was successfully updated."
    else
      flash[:alert] = @receipt.errors.full_messages.join(", ")
      render action: "edit"
    end
  end

  def destroy
    @receipt = Receipt.find(params[:id])
    @receipt.update_attributes(:status_id => Status::KEEP_IN_VIEW)

    respond_to do |format|
      format.html { redirect_to receipts_url, notice: "Receipt No # #{@receipt.receipt_no} was dropped to KIV."  }
      format.json { head :no_content }
    end
  end
  
  def recover
    @receipt = Receipt.find(params[:id])
    @receipt.update_attributes!(:status_id => Status::ACTIVE)
    redirect_to kiv_receipts_url, :notice => "Receipt No # #{@receipt.receipt_no} has recovered from KIV."
  end
end