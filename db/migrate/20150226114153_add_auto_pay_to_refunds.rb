class AddAutoPayToRefunds < ActiveRecord::Migration[7.0]
  def change
    add_column :refunds, :automatic, :boolean, default: true
  end
end
