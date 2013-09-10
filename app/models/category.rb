# == Schema Information
#
# Table name: categories
#
#  id                 :integer          not null, primary key
#  name               :string(255)      not null
#  active             :boolean
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  parent_category_id :integer
#  exclusive          :boolean          default(FALSE)
#

# CHARTER
#   Classification for promotions (e.g., "Adventure", "Nightlife", "Clothing"). Many-to-many relationship with promotions.
#
# USAGE
#   You can assign multiple categories to a promotion. An "exclusive" category means it's only shown when you select it. If you
# select "All," it doesn't show up.
#
# Can also be hierarchical (unused at present). Default access is to "top level" or "root" categories. In the future we
#   can construct hierarchies with the parent_category_id
#
# NOTES AND WARNINGS
#   Promotions need to enforce the rule that an exclusive category assignment must be the only assignment. If you could assign
# them to other categories as well, they would get included in "All Items" anyway, which is inconsistent.
#
class Category < ActiveRecord::Base
  ALL_ITEMS_LABEL = 'Everything'
  ALL_ITEMS_ID = 'All'
  
  after_destroy :destroy_sub_categories
  
  attr_accessible :name, :active, :exclusive,
    		          :parent_category_id, :promotion_ids
  
  has_many :sub_categories, :class_name => 'Category', :foreign_key => 'parent_category_id'
  belongs_to :parent_category, :class_name => 'Category'
  
  has_and_belongs_to_many :promotions, :uniq => true
 
  # default_scope messes with sub_categories!
  scope :roots, where('parent_category_id is null')
  scope :active, where("active = #{ActiveRecord::Base.connection.quoted_true}")
  scope :exclusive, where("exclusive = #{ActiveRecord::Base.connection.quoted_true}")
  scope :non_exclusive, where("exclusive = #{ActiveRecord::Base.connection.quoted_false}")
  
  # Note that the db-level index is still case sensitive (on PG anyway)
  validates :name, :presence => true,
                   :uniqueness => { case_sensitive: false }
  validates_inclusion_of :active, :in => [true, false]
  
private
  def destroy_sub_categories
    self.sub_categories.each do |sub|
      sub.destroy
    end
  end
end
