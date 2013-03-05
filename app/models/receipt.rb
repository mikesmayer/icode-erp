class Receipt < ActiveRecord::Base
  before_save :cash_and_cheque
    
  attr_accessible :cash_amount, :cheque_amount, :journal_voucher_no, :receipt_date, :receipt_no, :remark, :total_amount, :trade_company_id, :updated_by, :status_id
  
  validates :receipt_no, :receipt_date, :trade_company_id, :cash_amount, :cheque_amount, :updated_by, :presence => true
  
  belongs_to :trade_company
  
  has_many :receipt_items, :dependent => :destroy
  
  def self.db_active(search)
    search.where(:status_id => Status::ACTIVE)
  end
  
  def self.db_kiv(search)
    search.where(:status_id => Status::KEEP_IN_VIEW)
  end
  
  private
  def cash_and_cheque
    self.total_amount = self.cash_amount.to_f + self.cheque_amount.to_f
  end
end