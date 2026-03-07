class AddMarketplaceSourceToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :marketplace_source, :string
    add_index :users, :marketplace_source, where: "marketplace_source IS NOT NULL"
  end
end
