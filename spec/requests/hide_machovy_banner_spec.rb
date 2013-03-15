describe "Hide machovy banner" do
  before do
    Metro.create!(:name => 'Pittsburgh')
    visit root_path
  end
  
  subject { page }
  
  it { should have_selector('#machovy_banner', :visible => true) }
  
  describe "Hide it", :js => true do
    before { click_link 'X' }
    
    it { should have_selector('#machovy_banner', :visible => false) }
  end
end
