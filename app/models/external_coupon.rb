# == Schema Information
#
# Table name: external_coupons
#
#  id              :integer          not null, primary key
#  metro_id        :integer
#  name            :string(255)      not null
#  address_1       :string(255)
#  address_2       :string(255)
#  deal_url        :string(255)      not null
#  store_url       :string(255)
#  source          :string(255)
#  phone           :string(14)
#  city            :string(50)
#  state           :string(2)
#  zip             :string(10)
#  deal_id         :integer          not null
#  user_name       :string(255)
#  user_id         :integer
#  title           :string(255)      not null
#  disclaimer      :text
#  deal_info       :text
#  expiration_date :date             not null
#  post_date       :datetime
#  small_image_url :string(255)      not null
#  big_image_url   :string(255)      not null
#  logo_url        :string(255)
#  deal_type_id    :integer
#  category_id     :integer
#  subcategory_id  :integer
#  distance        :decimal(, )
#  original_price  :decimal(, )
#  deal_price      :decimal(, )
#  deal_savings    :decimal(, )
#  deal_discount   :decimal(, )
#  slug            :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class ExternalCoupon < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]
  
  include ApplicationHelper
  
  after_save :assign_categories
  
  attr_accessible :address_1, :address_2, :big_image_url, :category_id, :city, :deal_discount, :deal_id, :deal_info, :deal_price, :deal_savings, 
                  :deal_type_id, :deal_url, :disclaimer, :distance, :expiration_date, :logo_url, :name, :original_price, :phone, 
                  :post_date, :small_image_url, :source, :state, :store_url, :subcategory_id, :title, :user_id, :user_name, :zip,
                  :metro_id, :category_ids
                  
  belongs_to :metro
  has_and_belongs_to_many :categories, :uniq => true
  
  validates_presence_of :name
  validates_presence_of :title
  validates_presence_of :expiration_date
  validates :deal_id, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :user_id, :numericality => { :only_integer => true, :greater_than => 0 }, :allow_blank => true
  validates :city, :length => { :maximum => MAX_ADDRESS_LEN }
  validates :state, :inclusion => { :in => US_STATES }, :allow_blank => true
  validates :phone, :format => { :with => US_PHONE_REGEX }, 
                    :length => { :maximum => User::PHONE_LEN }, :allow_blank => true
  validates :zip, :format => { :with => US_ZIP_REGEX },
                  :length => { :maximum => ZIP_PLUS4_LEN }, :allow_blank => true
  validates :deal_url, :format => { :with => URL_REGEX }
  validates :store_url, :format => { :with => URL_REGEX }, :allow_blank => true
  validates :logo_url, :format => { :with => URL_REGEX }, :allow_blank => true
  validates :small_image_url, :format => { :with => URL_REGEX }
  validates :big_image_url, :format => { :with => URL_REGEX }
  validates :original_price, :numericality => { :greater_than => 0 }, :allow_nil => true
  validates :deal_price, :numericality => { :greater_than_or_equal_to => 0 }, :allow_nil => true
  validates :deal_savings, :numericality => { :greater_than_or_equal_to => 0 }, :allow_nil => true
  validates :deal_discount, :numericality => { :greater_than_or_equal_to => 0 }, :allow_nil => true
  validates :deal_type_id, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
  validates :category_id, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :subcategory_id, :numericality => { :only_integer => true, :greater_than => 0 }
  validates :distance, :numericality => { :greater_than_or_equal_to => 0 }

  def expired?
    Time.zone.now > self.expiration_date
  end
  
private
  # Top level categories for 8Coupon
  RESTAURANTS = 1
  ENTERTAINMENT = 2
  BEAUTY = 3
  SERVICES = 4
  # There is no category id 5
  SHOPPING = 6
  TRAVEL = 7
  
  # http://api.8coupons.com/v1/getsubcategory gets categories and sub-categories
  # Update if this changes! Don't see an easy way to automate this. There are few enough it can be done with logic
  def assign_categories
    cats = Hash.new
    # Only hit the database once
    Category.all.each do |c|
      cats[c.name] = c
    end
    
    if RESTAURANTS == self.category_id
      self.categories << cats['Dining']
    elsif ENTERTAINMENT == self.category_id
      if [113, 114, 47, 56].include?(self.subcategory_id)
        # Parks/Adventures, Performing Arts, Museums, Travel
        self.category_ids << cats['Experiences']        
      elsif 48 == self.subcategory_id 
        # Bars/Pubs
        self.categories << cats['NightLife'] 
        self.categories << cats['Dining'] 
      elsif [49, 50, 51, 52, 53, 54, 55, 57].include?(self.subcategory_id)
        # Jazz/Blues; Theater, Karaoke, Dance Clubs, Comedy Clubs, Pool Halls, Lounges, Music Venues
        self.categories << cats['NightLife'] 
        self.categories << cats['Experiences'] 
      elsif 117 == self.subcategory_id # Bowling
        self.categories << cats['Sports'] 
      end
    elsif BEAUTY == self.category_id
      self.categories << cats['For Her'] 
    elsif SERVICES == self.category_id
      if [77, 76, 75, 69].include?(self.subcategory_id)
        # Fitness/Instruction, Gyms, Yoga, Health/Medical
        self.categories << cats['Wellness'] 
      elsif 72 == self.subcategory_id 
        # Travel/Hotels
        self.categories << cats['Experiences'] 
      else 
        self.categories << cats['Essentials'] 
      end
    elsif SHOPPING == self.category_id
      if 92 == self.subcategory_id 
        # Drugstores
        self.categories << cats['Wellness'] 
      elsif [96, 106].include?(self.subcategory_id) 
        # Hobby shops, sporting goods
        self.categories << cats['Sports'] 
      elsif [98, 131, 90, 116, 94, 93].include?(self.subcategory_id)
        # Jewelry, Women's fashion, Cosmetics, shoes, fashion
        self.categories << cats['For Her'] 
      elsif 101 == self.subcategory_id
        self.categories << cats['Over 18'] 
      else 
        self.categories << cats['Essentials'] 
      end
    elsif TRAVEL == self.category_id
      self.categories << cats['Experiences']
    end
  end
end
