Feature: Links in ToS
	As a user reading the ToS I want
	links to go to the right places
	
	Scenario: Following links on the ToS
		Given I am logged in as "myself" with password "password"
		When I am on the home page
			And I follow "Terms of Service" within "div#footer"
			
		# check	you're on the Terms of service page 
		
		Then I should see "Terms of Service" within ".tos h2"
			And I should see "While the Archive is in beta, it's important for users to be aware of what that means"
			
	  # all commented out lines concerning URLs lack a viable step definition
		#And the page URL should be "http://www.example.com/tos"
			
			And I should see the text with tags '<a href="#general">General Principles</a>'
			And I should see "General Principles" within ".toc"
			And I should see the text with tags '<a href="#age">Age Policy</a>'
			And I should see the text with tags '<a href="#privacy">Privacy Policy</a>'
			And I should see "Privacy Policy" within ".toc"
			And I should see "III. Archive Privacy Policy"
			And I should see the text with tags '<a href="#content">Content and Abuse Policies</a>'
			And I should see the text with tags '<a href="#assorted">Assorted Specialized Policies</a>'
			And I should see the text with tags '<a href="#IV.A.">procedures</a>'
			And I should see the text with tags '<a href="#IV.B.">spam and commercial promotion</a>'
			And I should see the text with tags '<a href="#IV.C.">threatening the technical integrity of the site</a>'
			And I should see the text with tags '<a href="#IV.D.">copyright</a>'
			And I should see the text with tags '<a href="#IV.E.">plagiarism</a>'
			And I should see the text with tags '<a href="#IV.F.">personal information and fannish identities</a>'
			And I should see the text with tags '<a href="#IV.G.">harassment</a>'
			And I should see the text with tags '<a href="#IV.H.">illegal and non-fanwork content</a>'
			And I should see the text with tags '<a href="#IV.K.">ratings and warnings</a>'
			
		# check that target links exist
   
			And I should see the text with tags '<a name="general" id="general">'
			#And the page URL should be "http://www.example.com/tos#general"
			And I should see the text with tags '<a name="age" id="age">'
			And I should see the text with tags '<a name="privacy" id="privacy">'
			And I should see the text with tags '<a name="content" id="content">'
			And I should see the text with tags '<a name="assorted" id="assorted">'
			And I should see the text with tags '<a name="IV.A.">'
			# And the page URL should be "http://www.example.com/tos#IV.A."
			And I should see the text with tags '<a name="IV.B.">'
			And I should see the text with tags '<a name="IV.C.">'
			And I should see the text with tags '<a name="IV.D.">'
			And I should see the text with tags '<a name="IV.E.">'
			And I should see the text with tags '<a name="IV.F.">'
			And I should see the text with tags '<a name="IV.G.">'
			And I should see the text with tags '<a name="IV.H.">'
			And I should see the text with tags '<a name="IV.K.">'
     
		# check following an internal link from the table of contents
 
		When I follow "Privacy Policy" within ".tos .toc"
		Then I should see "III. Archive Privacy Policy"
		# TODO: figure out why this isn't working
		# And the page URL should be "http://www.example.com/tos#privacy"
 
		# check following a link to the ToS FAQ
	
		When I follow "refer to the ToS FAQ" 
		 Then I should not see "What We Believe"
		 And I should see "There are a number of wonderful specialized archives."
		 #And the page URL should be "http://www.example.com/tos_faq#max_inclusiveness"
