describe "FeedbackMailer" do
  let(:user) { FactoryGirl.create(:user) }
    
  describe "Feedback email" do
    let(:name) { FactoryGirl.generate(:random_name) }
    let(:category) { ['Question', 'Comment', 'Complaint'].sample }
    let(:comment) { FactoryGirl.generate(:random_paragraphs) }
    
    let(:msg) { FeedbackMailer.feedback_email(name, category, comment, user.email) }
    
    it "should return a message object" do
      msg.should_not be_nil
    end
  
    it "should have the right sender" do
      msg.from.to_s.should match(user.email)
    end
    
    describe "Send the message" do
      before { msg.deliver }
        
      it "should get queued" do
        ActionMailer::Base.deliveries.should_not be_empty
        ActionMailer::Base.deliveries.count.should == 1
      end
      # msg.to is a Mail::AddressContainer object, not a string
      # Even then, converting to a string gives you ["<address>"], so match captures the intent easier
      it "should have the right sender" do
        msg.to.should be == ApplicationHelper::MACHOVY_FEEDBACK_ADMIN
      end
      
      it "should have the right subject" do
        msg.subject.should == FeedbackMailer::FEEDBACK_MESSAGE
      end
      
      it "should not have attachments" do
        msg.attachments.count.should == 0
      end
      
      it "should have the right content" do
        msg.body.encoded.should match("#{category} on Machovy")
       
        ActionMailer::Base.deliveries.count.should == 1
      end
    end
  end  
end
