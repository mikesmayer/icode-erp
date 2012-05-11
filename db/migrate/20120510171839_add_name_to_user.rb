class AddNameToUser < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :department_id, :integer
    add_index  :users, :department_id
  end
end
