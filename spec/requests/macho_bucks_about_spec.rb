describe "Macho Bucks about" do
  before { visit about_macho_bucks_path }
  
  subject { page }
  
  it { should have_selector('h1', :text => I18n.t('macho_bucks')) }
  
  pending "Should have gift links" do
    it { should have_link('Buy a gift certificate') }
    it { should have_link('Refer a friend or merchant') }
  end
end
