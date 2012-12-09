class ChangeIssueToValidDate < ActiveRecord::Migration
  def change
    rename_column :vouchers, :issue_date, :valid_date
  end
end
