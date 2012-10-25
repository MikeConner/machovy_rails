require 'affiliate_converter_factory'

describe "Affiliate conversion" do
  let(:factory) { AffiliateConverterFactory.instance }
  
  subject { factory }
  
  it { should respond_to(:create_converter) }
  
  describe "Amazon converter" do
    let(:converter) { factory.create_converter('http://www.amazon.com/blah/blah/blah') }
    
    subject { converter }
    
    it { should respond_to(:convert) }

    describe "convert valid urls" do
      {'http://www.amazon.com/gp/product/B006ZNBSA2?smid=ATVPDKIKX0DER' => 'https://www.amazon.com/dp/B006ZNBSA2?tag=machovy-20',
       'http://www.amazon.com/dp/B006ZNBSA2?smid=ATVPDKIKX0DER' => 'https://www.amazon.com/dp/B006ZNBSA2?tag=machovy-20',
       'http://www.amazon.com/dp/product/B006ZNBSA2?smid=ATVPDKIKX0DER' => 'https://www.amazon.com/dp/B006ZNBSA2?tag=machovy-20',
       'http://www.amazon.com/Maclaren_Stroller/dp/B006ZNBSA2?smid=ATVPDKIKX0DER' => 'https://www.amazon.com/dp/B006ZNBSA2?tag=machovy-20',
       'http://www.amazon.com/o/ASIN/B006ZNBSA2?smid=ATVPDKIKX0DER' => 'https://www.amazon.com/dp/B006ZNBSA2?tag=machovy-20',
       'http://www.amazon.com/exec/obidos/tg/detail/-/B006ZNBSA2?smid=ATVPDKIKX0DER' => 'https://www.amazon.com/dp/B006ZNBSA2?tag=machovy-20',
       'http://www.amazon.com/exec/obidos/tg/detail/blah-blah-blah/B006ZNBSA2?smid=ATVPDKIKX0DER' => 'https://www.amazon.com/dp/B006ZNBSA2?tag=machovy-20',
       'http://www.amazon.com/dp/B006ZNBSA2/more?smid=ATVPDKIKX0DER' => 'https://www.amazon.com/dp/B006ZNBSA2?tag=machovy-20',
       'http://www.amazon.com/dp/B006ZNBSA2' => 'https://www.amazon.com/dp/B006ZNBSA2?tag=machovy-20',
       'http://www.amazon.com/dp/B006ZNBSA2  ' => 'https://www.amazon.com/dp/B006ZNBSA2?tag=machovy-20',
       'http://www.amazon.com/dp/B007P4VOWC/ref=xs_gb_bd_CsB!FmuIall-?pf_rd_p=1392640362&pf_rd_s=center-2&pf_rd_t=701&pf_rd_i=20&pf_rd_m=ATVPDKIKX0DER&pf_rd_r=1RB4R35Q3Q3329AD6V0W' => 'https://www.amazon.com/dp/B007P4VOWC?tag=machovy-20',
       'https://www.amazon.com/dp/B006ZNBSA2?tag=machovy-20' => 'https://www.amazon.com/dp/B006ZNBSA2?tag=machovy-20',
       'https://www.amazon.com/gp/product/B006ZNBSA2?tag=machovy-20' => 'https://www.amazon.com/dp/B006ZNBSA2?tag=machovy-20'
      }.each do |source, dest|
        it "should accept #{source}" do
          converter.convert(source).should == dest
        end
      end
    end
    
    it "should work with general format" do
      converter.convert('http://www.amazon.com/dp/B006ZNBSA2?smid=ATVPDKIKX0DER', false).should == 'https://www.amazon.com/gp/product/B006ZNBSA2?tag=machovy-20'
    end
    
    it "should throw exception if not amazon" do
      url = FactoryGirl.generate(:random_url)

      expect { converter.convert(url) }.to raise_exception("Invalid Amazon.url " + url)
    end

    describe "convert invalid urls" do
      ['http://www.amazon.com/product/B006ZNBSA2?smid=ATVPDKIKX0DER',
       'http://www.amazon.com/hp/B006ZNBSA2?smid=ATVPDKIKX0DER',
       'http://www.amazon.com/dp/produkt/B006ZNBSA2?smid=ATVPDKIKX0DER',
       'http://www.amazon.com/Maclaren_Stroller/B006ZNBSA2?smid=ATVPDKIKX0DER',
       'http://www.amazon.com/o/B006ZNBSA2/ASIN?smid=ATVPDKIKX0DER',
       'http://www.amazon.com/exec/obidos/tg/detail/B006ZNBSA2?smid=ATVPDKIKX0DER'
      ].each do |url|
        it "should not accept #{url}" do
          converter.convert(url).should == url
        end
      end
    end
    
    it "should falsely accept if not validating ASIN length" do
      converter.convert('http://www.amazon.com/dp/produkt/B006ZNBSA2?smid=ATVPDKIKX0DER', true, false).should == 'https://www.amazon.com/dp/produkt?tag=machovy-20'
    end
  end
end
