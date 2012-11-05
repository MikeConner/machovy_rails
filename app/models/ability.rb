class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    user ||= User.new # guest user (not logged in)
    
    if user.has_role?(Role::SUPER_ADMIN)
      can :manage, :all
      can :access, :rails_admin      
    elsif user.has_role?(Role::CONTENT_ADMIN)
      can :read, [Promotion, Category, Video, Voucher, Order, Metro, BlogPost, Curator, Vendor, Position]
      can :create, [Order, Voucher]
      can :manage, [BlogPost, Promotion, PromotionLog, PromotionImage, Metro, Vendor, Voucher, User]
      cannot :destroy, [Promotion, Category, Video, Voucher, Order, Metro, Curator]
    elsif user.has_role?(Role::MERCHANT)
      can :read, [Curator, BlogPost, Video]
      can :create, [Promotion]
      can :manage, [Vendor, Promotion, PromotionLog, PromotionImage, Voucher]
      can :redeem, [Voucher]
    else
      # manage Promotion necessary to create an order; manage Voucher to generate qrcode
      can :read, [Promotion, Category, Video, Voucher, Order, Metro, BlogPost, Curator, Vendor, Position]
      can :create, [Order, Voucher]
      # manage Promotion necessary to create an order; manage Voucher to generate qrcode
      can :manage, [Promotion, Voucher, PromotionLog, User] 
      cannot :destroy, [Promotion, Category, Video, Voucher, Order, Metro]
    end

    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
