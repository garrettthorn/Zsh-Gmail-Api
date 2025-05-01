#! /bin/zsh

#after you've gotten your refresh token, client id, and client secret; you're ready to send an HTML email.  This script will go through the entire process

####################################functions & global variables############################################################################################################
refreshToken="YOUR REFRESH TOKEN HERE"
clientId="YOUR CLIENT ID HERE"
clientSecret="YOUR CLIENT SECRET HERE"
htmlEmailLocation="/private/tmp/message.html"

#function to get refreshed access_token from Gmail API
getGmailAPIAuthToken() {

    refreshToken="$1"
    clientId="$2"
    clientSecret="$3"

    key=$(curl https://oauth2.googleapis.com/token \
    --request POST \
    --data "access_type=offline&refresh_token=$refreshToken&client_id=$clientId&client_secret=$clientSecret&grant_type=refresh_token")

    #remove carriage returns, newlines, and tabs from the json string
    key=$(echo "$key" | tr -d '\r' | tr -d '\n' | tr -d '\t')

    #use jq to determine asset_id from JSON response
    access_token=$( echo $key | jq -r ".access_token" )

    #return auth_token
    echo $access_token
}

#function for creating an HTML email, passing the recipient and subject as arguments
createEmail() {

recipient="$1"
subject="$2"
messageLocation="$3"

#create a file at /private/tmp/message.html
cat <<EOF > $messageLocation
From: Sender <youremail@example.org>
To: $recipient
Subject: $subject
Date: $(date -R)
Reply-To: youremail@example.org
Content-Type: text/html; charset="UTF-8"

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
    <body>
        <h1>Hello world!</h1>
    </body>
</html>                 
EOF

}

#after the email has been compiled, this function sends the email when passed the gmail API token; then removes the temporary HTML file we created
sendEmail() {

    messageLocation="$1"
    accessToken="$2"

    result=$( curl -X POST \
      -H "Authorization: Bearer $accessToken" \
      -H "Content-Type: message/rfc822" \
      --data-binary @$messageLocation \
      "https://gmail.googleapis.com/upload/gmail/v1/users/me/messages/send")


    echo $result

    #remove the created HTML message after it's been sent
    rm $messageLocation

}



####################################MAIN############################################################################################################

#obtain our access token
gmailAccessToken=$( getGmailAPIAuthToken "$refreshToken" "$clientId" "$clientSecret" )

#create the html email, passing the recipient, subject, and message location
createEmail "user@example.com" "HTML Email - Hello World!" "$htmlEmailLocation"

#send the email, grabbing the response from the API to verify it sent; passing the message location and the access token we obtained earlier
apiResponse=$( sendEmail "$htmlEmailLocation" "$gmailAccessToken" )

echo $apiResponse