#! /bin/zsh

#Setting Up Authorization

#Navigate to https://console.cloud.google.com/
#Create a new project
#Go to Navigation Menu on top left > APIs & Services > Library
#Search for Google Sheets API and click Enable
#You'll be taken to the sheets page, click Credentials > create credentials > OAuth Client ID
#Click Configure Consent Screen
    #Click Get Started
    #Enter app name & user support email
    #Choose internal or external - this just depends if you'd like this oAuth app available to other users
    #Enter contact email
    #Agree to user data policy
    #Click Create
    #Click Create oAuth client
    #For application type, select Desktop App
    #Copy the client ID and client secret that are generated

clientId="INSERT YOUR CLIENT ID HERE"
clientSecret="INSERT YOUR CLIENT SECRET HERE"

#Select Data Access and Add or remove scopes
    #Search for the https://www.googleapis.com/auth/gmail.send scope and add it, then save
#Select Audience and under Testing, click Publish app
#In a browser (where you're signed into your gmail account), paste the following URL but replace the client_id
    #   https://accounts.google.com/o/oauth2/auth?client_id=YOUR CLIENT ID HERE&redirect_uri=http://localhost:3000&scope=https://www.googleapis.com/auth/gmail.send&response_type=code&include_granted_scopes=true&access_type=offline&state=state_parameter_passthrough_value
#Go through the consent screen (you will likely have to click advanced and "Go to NAME OF YOUR APP (unsafe)")
#Agree to the scope, which requests to send emails on your behalf; when you finally see the local host page, copy the url.  it will look something like this:
    #   http://localhost:3000/?state=state_parameter_passthrough_value&code=YOUR CODE&scope=https://www.googleapis.com/auth/gmail.send
#retrieve the returned code from the URL, which we will use in the call below:
code="INSERT YOUR CODE HERE"

#this is the call that will provide you with an access token as well as a refresh token, which you can use to make subsequent requests for new access tokens.
refreshCodeResponse=$( curl "https://accounts.google.com/o/oauth2/token" -s --request POST --data "code=$code&client_id=$clientId&client_secret=$clientSecret&redirect_uri=http://localhost:3000&grant_type=authorization_code" )

echo $refreshCodeResponse

#within this json response, you will see the refresh_token value.  
#now you have the three elements (clientID, clientSecret, and refreshToken) that will allow you to always get a refreshed access token and send mail via zsh or bash script

