class ProductsDatatable
	def datatable
	  @objects = current_objects(params)
	  @total_objectss = total_objects(params)
	  render :layout => false
	end

	private

	def current_objects(params={})
	  current_page = (params[:iDisplayStart].to_i/params[:iDisplayLength].to_i rescue 0)+1
	  @current_objects = DeliveryOrderItem.paginate :page => current_page, 
	                                     :include => [:user], 
	                                     :order => "#{datatable_columns(params[:iSortCol_0])} #{params[:sSortDir_0] || "DESC"}", 
	                                     :conditions => conditions,
	                                     :per_page => params[:iDisplayLength]
	end

	def total_objects(params={})
	  @total_objects = DeliveryOrderItem.count :include => [:user], :conditions => conditions
	end


	def datatable_columns(column_id)
	  
case column_id.to_i
    when 2
      return "objects.do_date"
    when 3
      return "objects.delivery_order.do_date"
    when 4
      return "objects.delivery_order.trade_company.name"
    when 5
      return "objects.delivery_order.trade_company.trade_term.name"
    when 6
      return "objects.delivery_order.sales_tax_exemption_no"
    when 7
      return "objects.delivery_order.trade_company.sales_tax_no"     
    else
      return "objects.delivery_order.sales_rep"
	end

	def conditions
	  conditions = []
	  conditions << "(objects.do_date ILIKE '%#{params[:sSearch]}%' OR users.name ILIKE '%#{params[:sSearch]}%')" if(params[:sSearch])
	  return conditions.join(" AND ")
	end
end