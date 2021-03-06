class DeliveryOrderManagement
  
  def self.running_delivery_order_items(data, delivery_order)
    if data.present?
      delivery_order.delivery_order_items.delete_all if delivery_order.delivery_order_items.present?
      data.each do |key, content|
        d_order = delivery_order.delivery_order_items.build( :sales_order_item_id => content[:sales_order_item_id],
                                                             :so_date => content[:so_date],
                                                             :delivery_qty => content[:delivery_qty],
                                                             :order_qty => content[:order_qty],
                                                             :unit_price => content[:unit_price],
                                                             :balance_qty => content[:balance_qty],
                                                             :no_of_carton => content[:no_of_carton],
                                                             :gen_current_stock => content[:gen_cur_stock],
                                                             :part_no => content[:part_no],
                                                             :client_lot => content[:client_lot],
                                                             :client_po => content[:client_po] )
        unless d_order.valid?
          return false, msg = d_order.errors.full_messages
          break;
        end
      end
      return delivery_order
    end
  end
  
  def self.manage_inventory_and_product(delivery_order)
    if delivery_order.present?
      if delivery_order.delivery_order_items.present?
        delivery_order.delivery_order_items.each do |doi|
          if doi.present?
            if doi.sales_order_item.present?
              InventoryHistory.create!(:product_id => doi.sales_order_item.product_id, :stock_in => 0, :stock_out => doi.delivery_qty, :amount => doi.gen_current_stock, :inventory_issue_id => InventoryIssue.find_by_description("DELIVERY ORDER").id)
              doi.sales_order_item.product.update_attributes!(:current_stock => doi.gen_current_stock)
              doi.sales_order_item.update_attributes!(:remaining_qty => doi.balance_qty)
              doi.sales_order_item.update_attributes!(:status => SalesOrderItem::COMPLETED) if doi.so_balance_qty_is_zero?
              self.shipping_full_stock(doi.sales_order_item)
            end
          end
        end
        self.insert_account_statement(delivery_order)
        self.insert_sales_tax_exemption(delivery_order) if delivery_order.sales_tax_exemption_id.present?
      end
    end
  end
  
  def self.shipping_full_stock(soi)
    count     = 0
    so        = soi.sales_order
    max_count = so.sales_order_items.count
    so.sales_order_items.each { |soi| count += 1  if soi.is_completed? }
    so.update_attributes!(:status => SalesOrder::COMPLETED) if count == max_count
  end
  
  def self.insert_account_statement(d_order)
    if d_order.present?
      d_order.statement_of_accounts.new(:trade_company_id => d_order.trade_company_id, :transaction_date => Date.today, :transaction_type => "INV", :credit_note_id => 0, :debit_note_id => 0, :delivery_order_id => d_order.id)
      d_order.save!
    end
  end
  
#  def self.insert_sales_tax_exemption(d_order)
#    ste_id = d_order.sales_tax_exemption_id
#    d_order.delivery_order_items.each do |doi|
#      d_qty = doi.delivery_qty
#      
#      if doi.sales_order_item.present?
#        if doi.sales_order_item.product.present?
#          if doi.sales_order_item.product.tarif_code.present?
#            product_tarif_code = doi.sales_order_item.product.tarif_code
#          end
#        end
#      end
#      
#      # The important is we don't check the perihal barang, only check with tarif_code, :)
#      @brg = SalesTaxExemptionBarang.where("sales_tax_exemption_id = ? and tarif_code = ? and valid_weight_condition = ?", ste_id, product_tarif_code, true)
#      if @brg.present?
#        @brg.each do |brg|
#          brg.complete_qty  += d_qty.to_i
#          brg.available_qty -= d_qty.to_i
#          brg.save!
#        end
#      end
      
#      before_available_qty = barang.available_qty
#      after_available_qty  = before_available_qty.to_f - pri.quantity.to_f
#      after_complete_qty   = barang.complete_qty.to_f + pri.quantity.to_f
#      stei = SteSupplierHistory.new(:sales_tax_exemption_id => @vendor_id.sales_tax_exemption.id, :product_id => pri.product_id, :purchase_order_id => po_id, :purchase_order_item_line_id => @poil.id, :before_available_qty => before_available_qty, :after_available_qty => after_available_qty, :accumulative_complete_qty => after_complete_qty)
#      stei.save!
#      barang.update_attributes!(:complete_qty => after_complete_qty, :available_qty => after_available_qty)
      
#    end
#    d_order
#  end
#end



  def self.insert_sales_tax_exemption(d_order)
    @doi = d_order.delivery_order_items
    @customer_id = TradeCompany.find(d_order.trade_company_id)
    if @doi.present?
      @doi.each do |doi|
        product = doi.try(:sales_order_item).try(:product)
        if @customer_id.sales_tax_exemption.present?
          if @customer_id.sales_tax_exemption.sales_tax_exemption_barangs.present?
            @barangs = @customer_id.sales_tax_exemption.sales_tax_exemption_barangs
            if @barangs.present? && product.present?
              if product.tarif_code.present?
                # it is Sales Tax Exemption if the supplier has provided the licence.
                barang = @barangs.find_by_tarif_code(product.tarif_code)
                if barang.present?
                  before_available_qty = barang.available_qty
                  if barang.need_part_weight == true
                    wtpc = doi.delivery_qty.to_f * product.part_weight.to_f
                    after_available_qty  = before_available_qty.to_f - wtpc
                    after_complete_qty   = barang.complete_qty.to_f + wtpc
                    stei = SteCustomerHistory.new(:sales_tax_exemption_id => @customer_id.sales_tax_exemption.id, :product_id => product.id, :trade_company_id => @customer_id.id, :delivery_order_item_id => doi.id, :unit_measurement_id => doi.sales_order_item.unit_measurement_id, :before_available_qty => before_available_qty, :after_available_qty => after_available_qty, :accumulative_complete_qty => after_complete_qty, :delivery_qty => doi.delivery_qty, :pc_weight => product.part_weight.to_f)
                  else
                    after_available_qty  = before_available_qty.to_f - doi.delivery_qty.to_f
                    after_complete_qty   = barang.complete_qty.to_f + doi.delivery_qty.to_f
                    stei = SteCustomerHistory.new(:sales_tax_exemption_id => @customer_id.sales_tax_exemption.id, :product_id => product.id, :trade_company_id => @customer_id.id, :delivery_order_item_id => doi.id, :unit_measurement_id => doi.sales_order_item.unit_measurement_id, :before_available_qty => before_available_qty, :after_available_qty => after_available_qty, :accumulative_complete_qty => after_complete_qty)
                  end
                  stei.save!
                  barang.update_attributes!(:complete_qty => after_complete_qty, :available_qty => after_available_qty)
                  check_overweight(barang)
                end
              end
            end
          end
        end
      end
    end
  end
  
  private
  
  def check_overweight(brg)
    brg.update_attributes(:valid_weight_condition => false) if brg.available_qty <= 0
  end
end