class CreditNote < ActiveRecord::Base
  before_save :uppercase_text
  before_update :uppercase_text
  
  attr_accessible :account_id, :amount, :credit_note_date, :credit_note_no, :credit_type, :updated_by, :trade_company_id, :currency_id, :status_id
  
  validates :credit_note_no, :amount, :credit_note_date, :credit_type, :updated_by, :trade_company_id, :currency_id, :presence => true
  
  belongs_to :trade_company
  belongs_to :currency
  
  default_scope order("credit_note_no DESC")
  
  def self.db_active(search)
    search.where(:status_id => Status::ACTIVE)
  end
  
  def self.db_kiv(search)
    search.where(:status_id => Status::KEEP_IN_VIEW)
  end
  
  def updater_name
    User.find_by_id(self.updated_by).name
  end
  
  def update_credit_thing(company)
    company.total_amount      += self.amount
    company.sn_credit_note_no  = self.credit_note_no
    company.save!
  end
  
  def uppercase_text
    self.credit_type.upcase! if self.credit_type.present?
  end
end