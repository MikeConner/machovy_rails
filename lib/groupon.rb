# coding: utf-8

require 'singleton'

class Groupon
  include Singleton

  DEFAULT_CATEGORY = 'Essentials'
  
  # Groupon categories, from their downloaded Excel file
  ARTS = 'Arts and Entertainment'
  CARS = 'Automotive'
  BEAUTY = 'Beauty & Spas'
  EDUCATION = 'Education'
  MONEY = 'Financial Services'
  FOOD = 'Food & Drink'
  HEALTH = 'Health & Fitness'
  HOME = 'Home Services'
  LEGAL = 'Legal Services'
  NIGHTLIFE = 'Nightlife'
  PETS = 'Pets'
  SERVICES = 'Professional Services'
  GOVERNMENT = 'Public Services & Government'
  REAL_ESTATE = 'Real Estate'
  RELIGION = 'Religious Organizations'
  RESTAURANTS = 'Restaurants'
  SHOPPING = 'Shopping'
  TRAVEL = 'Travel'
  UNKNOWN = 'Unknown'
  
  # Machovy Categories
  M_NIGHTLIFE = 'NightLife'
  M_ESSENTIALS = 'Essentials'
  M_HOBBIES = 'Hobbies'
  M_ELECTRONICS = 'Electronics'
  M_DINING = 'Dining'
  M_EXPERIENCES = 'Experiences'
  M_WELLNESS = 'Wellness'
  M_FOR_HER = 'For Her'
  M_AFTER_HOURS = 'After Hours'
  
  attr_accessor :link_array, :link_hash
  
  def initialize
    @link_array = []
    @link_hash = Hash.new

    @goods = JSON.parse(open("http://api.groupon.com/v2/deals?client_id=#{GROUPON_CLIENT_ID}&area=pittsburgh&channel_id=goods").read)
    @getaways = JSON.parse(open("http://api.groupon.com/v2/deals?client_id=#{GROUPON_CLIENT_ID}&area=pittsburgh&channel_id=getaways").read)
    
    @goods['deals'].each do |deal|
      next if 'closed' == deal['status']
      next if categorize(deal).nil?
      
      @link_array.push(deal)
      @link_hash[deal['id']] = deal
    end
    
    @getaways['deals'].each do |deal|
      next if 'closed' == deal['status']
      next if categorize(deal).nil?
      
      @link_array.push(deal)
      @link_hash[deal['id']] = deal
    end
  end
  
  def self.deals_page(metro)
    "http://www.groupon.com/browse/#{metro.downcase}?z=dealpage"
  end
  
  def self.cj_url(url, user)
    "http://www.anrdoezrs.net/click-#{GROUPON_PID}-10804307?sid=#{user}&url=#{CGI::escape(url)}"
  end
  
  def filter_links(active_category)
    @links = []
    
    if active_category.nil? or Category::ALL_ITEMS_ID == active_category
      non_exclusive = Category.non_exclusive.map { |c| c.name }
      self.link_array.each do |link|
        if !(categorize(link) & non_exclusive).empty?
          @links.push(link)
        end
      end
    else    
      self.link_array.each do |link|
        if categorize(link).include?(active_category)
          @links.push(link)
        end
      end
    end

    @links.shuffle
  end

  def categorize(link)
    result = []
    
    case link['tags'].count
    when 0
    when 1
      cat = general_category(link['tags'][0]['name'])
      if !cat.nil? and (UNKNOWN == cat[0])
        cat = specific_category(link['tags'][0]['name'])
      end
      
      result += cat unless cat.nil?
    else # could be 2 or more
      # If there are two, check to see if we need to look at the second one; some are obvious
      cat = general_category(link['tags'][0]['name'])
      if !cat.nil?
        result += cat unless UNKNOWN == cat[0]
        cat = specific_category(link['tags'][1]['name'])
        if cat.nil?
          # If specific category causes it to be rejected, clear any general result
          result = []
        elsif UNKNOWN != cat[0]
          result = cat
        end
      end
    end
    
    result.uniq
  end
  
  # Return nil to reject the deal entirely, based on the main category. Groupons can have from 0-2 tags. We're rejecting untagged ones (rare).
  # If there are two, the first tag is the general category, and the second tag is the specific category.
  # The problem is single tags might be *either* a general or specific category. So, if not rejected but not found, it's probably a speciic tag, return [UNKNOWN]
  def general_category(tag)
    case tag
    when ARTS
      [M_EXPERIENCES]
    when CARS
      [M_HOBBIES]
    when BEAUTY
      [M_FOR_HER]
    when EDUCATION
      [M_ESSENTIALS]
    when MONEY
      [M_ESSENTIALS]
    when FOOD
      [M_DINING]
    when HEALTH
      [M_WELLNESS]
    when HOME, PETS, GOVERNMENT, RELIGION
      nil
    when LEGAL
      [M_ESSENTIALS]
    when NIGHTLIFE
      [M_NIGHTLIFE]
    when SERVICES
      [M_ESSENTIALS]
    when REAL_ESTATE
      [M_ESSENTIALS]
    when RESTAURANTS
      [M_DINING]
    when SHOPPING
      [M_ESSENTIALS]
    when TRAVEL
      [M_EXPERIENCES]
    else
      [UNKNOWN]
    end  
  end
  
  # This is tedious, but given that there is an enumerated list, however long, it's better for performance (and maintenance) to have a quick, deterministic
  # classification. The alternative, which I would have to do if they had open-ended categorization, would be writing a real text classifier.
  def specific_category(tag)
    # Eliminate stuff off the bat if it's clearly not part of the brand
    if ['Amusement Parks', 'Aquariums', 'Arcades', 'Arts & Crafts Activites', 'Ballet & Dance', 'Botanical Gardens',"Children's Museum",
        'Circus', 'Dance Companies', 'Fun Centers', 'Go Karts',"Kid's Activities", 'Miniature Golf', 'Museums', 'Opera', 'Psychics & Astrologers',
        'Segway Tours', 'Theme Parks', 'Tours', 'Walking Tours', 'Water Parks', 'Zoos', 'Scooters & Mopeds', 'Beauty Supply', 'Day Spas',
        'Eyelash Services', 'Hair Removal', 'Hair Salons & Barbers', 'Makeup Artists', 'Massage', 'Medical Spas', 'Nail Salons', 'Skin Care & Facials',
        'Waxing', 'Adult Education', 'Business Schools', 'Catholic Schools', 'Charter Schools', 'Colleges & Universities', 'Cosmetology Schools',
        'Educational Services', 'Educational Supply Stores', 'Elementary Schools', 'Graduate Schools', 'Language Schools', 'Massage Schools',
        'Middle Schools & High Schools', 'Parochial Schools', 'Preparatory Schools', 'Preschools', 'Private Schools', 'Private Tutors', 
        'Banks & Credit Unions', 'Check Cashing/Pay-day Loans', 'Credit Counseling Services', 'Insurance', 'Acupuncture', 'Addiction Treatment Centers',
        'Adult Day Care Centers', 'Allergists', 'Alternative Medicine Practitioners', 'Ambulance Services', 'Anesthesiologists', 'Aromatherapy',
        'Assisted Living Facilities', 'Bootcamps', 'Cannabis Clinics/Evaluations', 'Cardiologists', 'Child Psychologists', 'Counseling & Mental Health',         'Gerontologists', 'Neonatal Physicians', 'Obstetricians and Gynecologists', 'Pediatric Dentists', 'Pediatricians',
        'Agricultural Services', 'Appliance Repair & Supplies', 'Building Supplies', 'Carpet Cleaning', 'Carpeting', 'Chimney Sweep', 
        'Cleaning Services & Supplies', 'Interior Designers & Decorators', 'Pest & Animal Control', 'Utilities - Gas, Water & Electric', 
        'Vacuum Cleaners', 'Waste Management Services', 'Adoption Services', 'Animal Hospitals', 'Animal Shelters', 'Breeders', 'Dog Walkers', 
        'Horse Services & Equipment', 'Pet Boarding/Pet Sitting', 'Pet Groomers', 'Pet Stores', 'Pet Training', 'Veterinarians', 'Charity', 'Child Day Care', 
        'Copy Shops', 'Courier & Delivery Services', 'Diaper Services', 'Family Counselors', 'Fashion Design', 'Funeral Services & Cemeteries', 
        'Genealogists', 'Furniture Reupholstery', 'Junk Removal and Hauling', 'Life Coaches', 'Marketing', 'Non-Profit Organizations', 'Notaries', 
        'Printing & Copying Equipment & Services', 'Public & Social Services', 'Shipping Centers & Mail Services', 'Taxidermy', 'Volunteer Organizations', 
        'Wedding Planning', 'Departments of Motor Vehicles', 'Government Services', 'Landmarks & Historical Buildings', 'Libraries', 'Police Departments', 
        'Post Offices', 'Home Staging', 'Housing Assistance & Shelters', 'Mobile Home Dealers', 'Mobile Home Parks', 'Moving Services', 
        'Retirement Communities', 'Title Companies', 'University Housing', 'Missions', 'Monasteries', 'Mosques', 'Synagogues', 'Appliances', 
        'Arts & Crafts Supplies', 'Baby Furniture', 'Auctions', 'Baby Gear', 'Bridal', 'Cards & Stationery', 'Carpet & Flooring',"Children's Clothing", 
        'Collectibles', 'Comic Books', 'Dance Apparel', 'Department Stores', 'Discount Stores', 'Fabric Stores', 'Flea Markets', 'Furniture Stores', 
        'Hardware Stores', 'Junk & Scrap Dealers', 'Kitchen & Bath', 'Lighting Fixtures', 'Luggage', 'Mattresses', 'Nurseries & Garden Centers', 
        'Office Supplies & Equipment', 'Outlet Stores', 'Religious Goods', 'Shades & Blinds', 'Thrift Stores', 'Toy Stores', 'Uniforms', 
        'Used, Vintage & Consignment', 'Country Clubs', 'Acting Classes', 'Art Classes', 'Specialty Schools', 'Swimming Lessons',
        'Convenience Stores', 'Fertility', 'Holistic Medicine', 'Naturopathic', 'Retirement Homes', 'Gardeners', 'Gutter Cleaning Services',
        'Home Cleaning', 'Sprinklers & Irrigation', 'Governmental Law', 'Juvenile Lawyers', 'Labor & Employment Lawyers', 'Malpractice Lawyers',
        'Patent, Trademark & Copyright Lawyers', 'Personal Injury Lawyers', 'Real Estate Lawyers', 'Accountants', 'Advertising', 'Appraisers',
        'Caretakers', 'Construction Companies', 'Consultants', 'Demolition Companies', 'Engineers', 'Freight Services', 'Graphic Design',
        'Publishers', 'Recycling Centers', 'Screen Printing & Embroidery', 'Secretarial Services', 'Self Storage', 'Video & Film Production',
        'Website Design', 'Writing Services', 'Apartments', 'Appraisers', 'Condominiums', 'Facilities & Warehouses', 'Portable Buildings',
        'Real Estate Appraisers', 'Antiques', 'Book Stores', 'Costumes', 'Framing', 'Home Décor', 'Industrial Equipment Supplier',
        'Newspapers & Magazines', 'Shopping Centers', 'Trophies & Engraving', 'Vending Machines', 'Timeshare Agencies', 'Vacation Home Rental',
        'Clothing Sales', HOME, PETS, GOVERNMENT, RELIGION].include?(tag)
      nil
    elsif tag =~ /church/i
      nil
    elsif tag =~ /temple/i
      nil
    else
      case tag
      when 'Art Galleries'
        [M_HOBBIES, M_EXPERIENCES]
      when 'Biking', 'Boating', 'Bowling', 'Canoe & Kayak Rentals', 'Casinos', 'Fishing', 'Plane & Helicopter Tours', 'Gambling & Gaming', 'Hot Air Balloon',
           'Laser Tag', 'Paintball', 'Skating', 'Skydiving', 'Speedway', 'Sporting Events', 'Piercing', 'Tattoo Removal', 'Tattoos', 'Boating & Sailing Classes',
           'Comedy Classes', 'Cooking Classes', 'Culinary Schools', 'Dance Lessons', 'Driving Lessons', 'Flight Instruction', 'Music Lessons',
           'Training & Vocational Schools', 'Trucking Schools', 'Voice Lessons', 'Wine Classes', 'Home Brewing', 'Rock Climbing', 'Skiing', 
        [M_HOBBIES, M_EXPERIENCES]
      when 'Dinner Theater'
        [M_DINING, M_EXPERIENCES]
      when 'Entertainment', 'Festivals'
        [M_EXPERIENCES]
      when 'Live Music', 'Movie Theaters', 'Symphony & Orchestra', 'Theater & Plays', 'Bartending Schools', 'Dating Services', 'DJs', 
           'Music Production', 'Recording & Rehearsal Studios', 'Singing Telegrams', 'Ticket Sales'
        [M_NIGHTLIFE, M_EXPERIENCES]
      when 'Yacht Clubs', 'Motorcycle Dealers', 'Motorcycle Repair', 'Car Dealers', 'Stereo Installation', 'Golf', 'Martial Arts', 'Tennis',
           'Photographers', 'Modeling', 'Bike Shops', 'Hobby Shops', 'Musical Instruments', 'Photography Stores & Services'
        [M_HOBBIES]    
      when 'Automotive', 'Auto Glass Services', 'Auto Parts & Accessories', 'Auto Repair & Services', 'Body Shops & Painting', 
           'Car Wash & Detailing', 'Gas & Services Stations', 'Oil Change Stations', 'Parking', 'Tires & Wheels', 'Towing',"Men's Salons",
           'Tanning Salons', 'Financial Advising', 'Investing', 'Mortgage Brokers', 'Stock Brokers', 'Tax Preparation', 'Food Delivery Services',
           'Fruits & Veggies', 'Gourmet Foods', 'Grocery Stores', 'Health Stores', 'Ice Cream & Frozen Yogurt', 'Seafood Markets', 'Specialty Food',
           'Cable & Satellite Equipment & Services', 'Contractors', 'Custom Home Builders', 'Electricians', 'Fire Protection', 'Fireplaces',
           'Garage Doors', 'Handyman Services', 'Home Inspectors', 'Home Repair', 'Home Theatre Installation', 'Keys & Locksmiths', 'Landscape Architects',
           'Landscaping', 'Lawn Care Services', 'Movers', 'Painters', 'Plumbing', 'Pool Cleaners', 'Roofing', 'Security Systems', 'Snow Removal Services',
           'Solar Installation', 'Swimming Pool Equipment & Supplies', 'Tree Services', 'Water Heaters', 'Window Installation', 'Window Washing',
           'Business & Corporate Lawyers', 'Financial & Bankruptcy', 'General Litigation Lawyers', 'Wills & Estate Planning', 'Architects',
           'Career Counseling', 'Dry Cleaning & Laundry', 'Electronics Repair', 'Employment Agencies', 'Equipment Rental', 'Equipment Repair',
           'General Contractors', 'Internet Services Providers', 'Investigation Services', 'IT Services & Computer Repair', 'Personal Shopping',
           'Portrait Studios', 'Recruiters', 'Shoe Repair', 'Watch Repair', 'Property Management', 'Real Estate Agents', 'Real Estate Services',
           'Truck Rental', 'Art', 'Computers', 'Drugstores', 'Formal Wear', 'Home Improvement Stores', 'Hot Tub and Pool', 'Leather Goods',
           "Men's Clothing", 'Mobile Phones', 'Music & DVDs', 'Pawn Shops', 'Swimwear', 'Watches', 'Wholesale Stores'
        [M_ESSENTIALS]
      when 'Liquor Stores', 'Wine Shops', 'Wineries', 'Bail Bonds', 'Criminal Lawyers', 'Divorce and Family Law', 'Driving & Traffic Law', 
           'Family Law Attorney', 'Party Supplies', 'Taxis'
        [M_NIGHTLIFE, M_ESSENTIALS]
      when 'Bagel Shops', 'Bakeries', 'Breweries', 'Butchers & Meat Shops', 'Candy Stores', 'Cheese Shops', 'Chocolate Shops', 'Espresso Bars',
           'Ethnic Foods', 'Farmers Market', 'Juice Bars & Smoothies', 'Snack Bars', 'Takeout'
        [M_DINING]
      when 'Chiropractors', 'Cosmetic Dentistry / Teeth Whitening', 'Cosmetic Surgeons', 'Dentists', 'Dermatologists', 'Detoxification', 'Doctors',
           'Ear, Nose & Throat', 'Endodontists', 'Family Practice', 'Home Health Care', 'Hospitals', 'Infectious Disease Physicians', 'Internal Medicine',
           'Laser Eye Surgery/Lasik', 'Medical Groups', 'Nutritionists', 'Occupational Medical Physicians', 'Ophthalmologists', 'Optometrists',
           'Oral Surgeons', 'Orthodontists', 'Orthopedists', 'Osteopathic Physicians', 'Pain Management Physicians', 'Periodontists', 'Pharmacies',
           'Physical Therapy', 'Podiatrists', 'Proctologists', 'Psychiatrists', 'Urgent Care', 'Weight Loss Centers', 'Eyewear & Opticians'
        [M_WELLNESS]
      when 'Exercise Equipment',  'Gyms & Fitness Centers', 'Health Clubs', 'Personal Trainers', 'Racquetball Clubs', 'Recreation Centers',
           'Sports Medicine', 'Athletic Apparel', 'Sporting Goods'
        [M_HOBBIES, M_ESSENTIALS, M_WELLNESS]
      when 'Tobacco Shops', 'Videos and Video Game Rental', 'Airlines', 'Bed & Breakfasts', 'Bus Lines', 'Car Rental', 'Cruises', 'Hostels',
           'Hotels', 'Lodging', 'Motels', 'Resorts', 'RV - Recreational Vehicles', 'Travel Agencies'
        [M_HOBBIES, M_ESSENTIALS]
      when 'Midwives', 'Pilates', 'Yoga', 'Event Planner', 'Florists', 'Party & Event Planning', 'Sewing & Alterations', 'Accessories', 'Boutiques',
           'Gift Shops', 'Jewelry', 'Lingerie', 'Maternity Stores', 'Shoe Stores', "Women's Clothing"
        [M_FOR_HER] 
      when 'Bars', 'Champagne Bars', 'Cigar Bars', 'Cocktail Bars', 'Comedy Clubs', 'Dance Clubs', 'Dive Bars', 'Gay Bars', 'Hookah Bars', 'Irish Pubs',
           'Jazz & Blues Clubs', 'Karaoke', 'Lounges', 'Music Venues', 'Night Clubs', 'Piano Bars', 'Pool Halls', 'Pubs', 'Social Clubs', 'Sports Bars',
           'Wine Bars', 'Security Guards'
        [M_NIGHTLIFE]
      when 'Catering & Bartending Services', 'Personal Chefs'
        [M_NIGHTLIFE, M_DINING]
      when "Afghan", "African", "American", "Andouille", "Argentine", "Armenian", "Asian Fusion", "Barbeque", "Basque", "Belgian", "Brasseries", "Brazilian", 
           "Breakfast & Brunch", "British", "Buffets", "Burgers", "Burmese", "Café", "Cafeteria", "Cajun", "Cambodian", "Caribbean", "Cheese steaks", 
           "Chicken Wings", "Chinese", "Coffee House", "Continental", "Creole", "Creperies", "Cuban", "Cyber Café", "Delis", "Dessert", "Dim Sum", "Diners", 
           "English", "Ethiopian", "Family", "Fast Food", "Filipino", "Fine Dining", "Fish & Chips", "Fondue", "Food Stands", "French", "Gastropubs", 
           "German", "Gluten-Free", "Greek", "Halal", "Hawaiian", "Himalayan", "Hot Dogs", "Hungarian", "Indian", "Indonesian", "Iranian", "Irish", "Italian", 
           "Jamaican", "Japanese", "Korean", "Kosher", "Latin American", "Lebanese", "Live Food", "Malaysian", "Mediterranean", "Mexican", "Middle Eastern", 
           "Modern European", "Mongolian", "Moroccan", "Nepalese", "Organic", "Oyster Bars", "Packaged Meals", "Pakistani", "Pancake House", "Persian", 
           "Peruvian", "Pizza", "Po Boys", "Polish", "Portuguese", "Raw Food", "Russian", "Sandwiches", "Scandinavian", "Seafood", "Singaporean", 
           "Small Plates", "Soul Food", "Soup", "Southern", "Southwestern", "Spanish", "Steakhouses", "Surinamese", "Sushi Bars", "Swiss", "Taiwanese", 
           "Tapas", "Tea Rooms", "Tex-Mex", "Thai", "Turkish", "Ukrainian", "Vegan", "Vegetarian", "Vietnamese"
        [M_DINING]
      when 'Electronics'
        [M_ELECTRONICS]
      end
    end
  end
end