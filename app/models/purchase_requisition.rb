class PurchaseRequisition < ActiveRecord::Base
  
  attr_accessible :pr_no,  :requested_by, :requested_by_date, :approved_by_level_two, :approved_by_level_two_date, :approved_by_level_three, :approved_by_level_three_date, :approved_by_level_five, :approved_by_level_five_date, :remark, :tasks, :status, :recover_status, :department_id

  belongs_to :product
  belongs_to :trade_company
  belongs_to :unit_measurement
  belongs_to :user, :foreign_key => "requested_by", :class_name => "User"
  belongs_to :b_task, :foreign_key => "tasks", :class_name => "PurchaseRequisition"
  
  has_one   :purchase_order
  has_many  :purchase_requisition_items, :dependent => :destroy
  
  LEVEL_ONE       = "LV1"   # Staff
  LEVEL_TWO       = "LV2"   # Supervisor
  LEVEL_THREE     = "LV3"   # General Manager
  LEVEL_FIVE      = "LV5"   # Director
  
  SUBMIT_PO       = "SUB_PO"
  SUBMIT_RN       = "SUB_RN"
  COMPLETED       = "COMPLETED"
  KEEP_IN_VIEW    = "KIV"
#  RECOVERED       = "RECOVERED"
  
  PR_NO = 1
  PR_STATUS = 2
  REQUESTOR = 3
  DEPARTMENT = 4
  
  ROLE = [
    InventoryManagementSystem::PR_MENU,
    InventoryManagementSystem::PR_NEW,
    InventoryManagementSystem::PR_SIGNATURE, 
    InventoryManagementSystem::PR_TRANSACTION,
    InventoryManagementSystem::PR_KIV_VIEW,
    InventoryManagementSystem::PR_ITEMS_KIV_VIEW,
    InventoryManagementSystem::PR_NEW_ADD_ITEMS,
    InventoryManagementSystem::PR_NEW_SHOW,             
    InventoryManagementSystem::PR_NEW_EDIT,             
    InventoryManagementSystem::PR_NEW_KIV,              
    InventoryManagementSystem::PR_NEW_PRINTABLE,  
    InventoryManagementSystem::PR_SIGNATURE_SHOW,
    InventoryManagementSystem::PR_SIGNATURE_EDIT,
    InventoryManagementSystem::PR_SIGNATURE_PRINTABLE,
    InventoryManagementSystem::PR_TRANSACTION_SHOW,     
    InventoryManagementSystem::PR_TRANSACTION_EDIT,     
    InventoryManagementSystem::PR_TRANSACTION_KIV,      
    InventoryManagementSystem::PR_TRANSACTION_PRINTABLE,
    InventoryManagementSystem::PR_DETAILS_SHOW,
    InventoryManagementSystem::PR_DETAILS_EDIT,
    InventoryManagementSystem::PR_DETAILS_PRINTABLE,
    InventoryManagementSystem::PR_KIV_SHOW,   
    InventoryManagementSystem::PR_KIV_RECOVER,
    InventoryManagementSystem::PR_ITEMS_KIV_SHOW,  
    InventoryManagementSystem::PR_ITEMS_KIV_RECOVER
  ]
  
  YES = 1 # got check box button - Maintenance, No product I/D
  NO  = 0 # no check box button  - has product I/D
  
  default_scope order("pr_no DESC")
  
  self.per_page = 50
  
  def self.search_purchase_requisitions(search)
    search.where("status != ?", PurchaseRequisition::KEEP_IN_VIEW)
  end
  
  def self.search_purchase_requisitions_kiv(search)
    search.where("status = ?",  PurchaseRequisition::KEEP_IN_VIEW)
  end
  
#  def ordered_by_pr_no
#    where("status != ?", PurchaseRequisition::KEEP_IN_VIEW)
#  end
  
#  scope :ordered_pr_no_kiv, where("status = ?", PurchaseRequisition::KEEP_IN_VIEW)

#  def self.generate_level(user)
#    if user.level == User::LEVEL_ONE
#      "LV2"
#    elsif user.level == User::LEVEL_TWO
#      "LV3"
#    elsif user.level == User::LEVEL_THREE
#      "LV5"
#    elsif user.level == User::LEVEL_FIVE
#      "SUB_PO"
#    else
#      "LV1"
#    end
#  end
  
  def update_to_cancel
    purchase_requisition_items.each {|cn| cn.update_attributes!(:status => PurchaseRequisitionItem::CANCEL)}
  end
  
#  def self.ordered_pr_no(search)
#    search.where("status != ?", PurchaseRequisition::KEEP_IN_VIEW)
#  end
  
  
  
  def self.search_engine(field_box, select_field)
    if select_field.to_i == PurchaseRequisition::PR_NO
      return where(:id => field_box)
    elsif select_field.to_i == PurchaseRequisition::PR_STATUS
      return where(:status => field_box)
    elsif select_field.to_i == PurchaseRequisition::REQUESTOR
      return where(:requested_by => field_box)
    elsif select_field.to_i == PurchaseRequisition::DEPARTMENT
      return where(:requested_by => field_box)
    else
      
    end
  end
  
  def self.uniq_status
    array = []
    pr = PurchaseRequisition.select('DISTINCT status')
    if pr.present?
      pr.each do |prs|
        if prs.status == PurchaseRequisition::LEVEL_ONE
          array << ["Level 1", prs.status]
        elsif prs.status == PurchaseRequisition::LEVEL_TWO
          array << ["Level 2", prs.status]
        elsif prs.status == PurchaseRequisition::LEVEL_THREE
          array << ["Level 3", prs.status]
        elsif prs.status == PurchaseRequisition::LEVEL_FIVE
          array << ["Level 5", prs.status]
        elsif prs.status == PurchaseRequisition::SUBMIT_RN
          array << ["PO Issued", prs.status]
        elsif prs.status == PurchaseRequisition::SUBMIT_PO
          array << ["Pending PO", prs.status]
        elsif prs.status == PurchaseRequisition::COMPLETED
          array << ["Completed", prs.status]
        else
          array << ["KIV", prs.status]
        end
      end
    end
    return array
  end
  
  def self.uniq_requestor
    array = []
    pr = PurchaseRequisition.select('DISTINCT requested_by');
    if pr.present?
      pr.each do |prn|
        user = User.find(prn.requested_by)
        array << [user.name, prn.requested_by]
      end
    end
    return array
  end
  
#  def self.uniq_department
#    department = []
#    pr = PurchaseRequisition.select('DISTINCT requested_by');
#    if pr.present?
#      pr.each do |prn|
#        user = User.find(prn.requested_by)
#        department << [user.department.name, prn.requested_by]
#      end
#    end
#    return department
#  end
  
  def self.logic(user)
    array_logic = []
#    if user.level == User::LEVEL_ONE
#      array_logic = [2,3,5]
#    elsif user.level == User::LEVEL_TWO
#      array_logic = [3,5]
#    elsif user.level == User::LEVEL_THREE
#      array_logic = [5]
#    elsif user.level == User::LEVEL_FIVE
#      array_logic = [1]
#    else
#      array_logic = [1,2,3,5]
#    end
    if user.has_level_two?
      array_logic << 2
    end
    if user.has_level_three?
      array_logic << 3
    end
    return array_logic
  end
  
  def self.managing_validate(user, select_items)
    msg = []
    if select_items.present?
      user_pending = user.purchase_requisition_items.where(:status => PurchaseRequisitionItem::PENDING).find(select_items)
      if user_pending.present?
        user_pending.each do |p|
          if p.eta < Date.today
            return false, msg << "ETA Should Have Future Date."
            break
          end
        end
      end
    else
      return false,  msg << "Please Select Items From Checkboxes."
    end
  end
  
#  def self.require_status(purchase_requisition)
#    user = User.find(purchase_requisition.requested_by)
#    if user.level_two == purchase_requisition.tasks
#      status = PurchaseRequisition::LEVEL_TWO
#    elsif user.level_three == purchase_requisition.tasks
#      status = PurchaseRequisition::LEVEL_THREE
#    elsif purchase_requisition.approved_by_level_five.blank?
#      status = PurchaseRequisition::LEVEL_FIVE
#    else
#      status = PurchaseRequisition::RECOVERED
#    end
#    return status
#  end
  
  def self.level_one_to(user, boss)
    ret = {}
    @requestor = User.find_by_id(user.requested_by)
    if @requestor.has_level_two?
      ret[:status] = PurchaseRequisition::LEVEL_TWO
      ret[:task] = @requestor.level_two
    elsif @requestor.has_level_three?
      ret[:status] = PurchaseRequisition::LEVEL_THREE
      ret[:task] = @requestor.level_three
    else
      ret[:status] = PurchaseRequisition::LEVEL_FIVE
      ret[:task] = boss.id
    end
    return ret
  end
  
  def self.level_two_to(user, boss)
    ret = {}
    @requestor = User.find_by_id(user.requested_by)
    if @requestor.has_level_three?
      ret[:status] = PurchaseRequisition::LEVEL_THREE
      ret[:task] = @requestor.level_three
    else
      ret[:status] = PurchaseRequisition::LEVEL_FIVE
      ret[:task] = boss.id
    end
    return ret
  end
  
  # It is script, for overwrite department id which belongs to department
#  def self.overwrite_department_id
#    @pr = PurchaseRequisition.all
#    @pr.each do |pr|
#      user = User.find_by_id(pr.requested_by)
#      pr.update_attributes!(:department_id => user.department_id)
#    end
#  end

end
