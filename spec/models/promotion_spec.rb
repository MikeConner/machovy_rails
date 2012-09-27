# == Schema Information
#
# Table name: promotions
#
#  id                   :integer         not null, primary key
#  title                :string(255)
#  description          :text
#  limitations          :text
#  voucher_instructions :text
#  teaser_image         :string(255)
#  retail_value         :decimal(, )
#  price                :decimal(, )
#  revenue_shared       :decimal(, )
#  quantity             :integer
#  start                :datetime
#  end                  :datetime
#  grid_weight          :integer
#  destination          :string(255)
#  metro_id             :integer
#  vendor_id            :integer
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#  main_image           :string(255)
#  curator_id           :integer
#

describe "Promotions" do
  pending "add some examples to (or delete) #{__FILE__}"
end
