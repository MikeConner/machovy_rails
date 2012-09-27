module VendorsHelper
  # Plus DC and territories
  US_STATES = %w(AK AL AR AS AZ CA CO CT DC DE FL GA HI IA ID IL IN KS KY LA MA MD ME MI MN MO MP MS 
                 MT NC ND NE NH NJ NM NV NY OH OK OR PA PR RI SC SD TN TX UT VA VI VT WA WI WV WY )
  US_PHONE_REGEX = /\(\d\d\d\) \d\d\d\-\d\d\d\d/
  URL_REGEX = /^((http|https)\:\/\/)?[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(:[a-zA-Z0-9]*)?\/?([a-zA-Z0-9\-\._\?\,\'\/\\\+&amp;%\$#\=~])*[^\.\,\)\(\s]$/
  US_ZIP_REGEX = /\d\d\d\d\d(-\d\d\d\d)?/
end
