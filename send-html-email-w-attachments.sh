#! /bin/zsh

#if you want to send an HTML email WITH an attachment, there are a few extra things we have to do.  This script will walk you through it

####################################functions & global variables############################################################################################################
refreshToken="YOUR REFRESH TOKEN HERE"
clientId="YOUR CLIENT ID HERE"
clientSecret="YOUR CLIENT SECRET HERE"
htmlFileLocation="/private/tmp/message.html"
emlFileLocation="/private/tmp/emailWithAttachment.eml"
fileAttachmentLocation="/Users/Shared/dog.jpeg"

#function to get refreshed access_token from Gmail API
getGmailAPIAuthToken() {

    #1 : Refresh Token - The refresh token from the Google Console Cloud that allows us to obtain a new access token
    #2 : Client ID - The client ID provided by Google Console Cloud
    #3 : Client Secret - The client secret provided by Google Console Cloud

    local refreshToken="$1"
    local clientId="$2"
    local clientSecret="$3"

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

#function for creating an HTML email, passing the message location
createHtmlEmail() {

    #1 : HTML Message Location - The location on our PC we'd like this HTML content to be written to

    local messageLocation="$1"

    #create a file at the provided message location with our HTML content
    cat <<EOF > $messageLocation
    <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
    <html>
        <body>
            <h1>Hello world - with attachments!</h1>
        </body>
    </html>                 
EOF

}

#function to create the MIME email 
createMimeEmail() {

  #1 : Email Subject - What the email is about, of course
  #2 : Message Location - Where the HTML file is stored
  #3 : Attachment File - What file would you like to attach (an image of a dog in our case!!)
  #4 : Email Recipient - Who you're sending the email to
  #5 : Location of our EML file - The file that will actually be sent to the Gmail API

  local emailSubject="$1"
  local emailBodyFile="$2"
  local attachmentFile="$3"
  local emailRecipient="$4"
  local tempMessageFile="$5"

  # Create the MIME message with mime-multipart
  boundary="boundary_$(date +%s)"

  # Create the email headers and body
  {
    echo "From: Your Name <you@example.com>"
    echo "To: ${emailRecipient}"
    echo "Subject: ${emailSubject}"
    echo "Cc: CC Recipient <person@example.com>"
    echo "MIME-Version: 1.0"
    echo "Reply-To: you@example.com"
    echo "Content-Type: multipart/mixed; boundary=${boundary}"
    echo
    echo "--${boundary}"
    echo "Content-Type: text/html; charset=UTF-8"
    echo "Content-Transfer-Encoding: 7bit"
    echo
    cat "${emailBodyFile}"
    echo
    echo "--${boundary}"
    echo "Content-Type: application/pdf"
    echo "Content-Transfer-Encoding: base64"
    echo "Content-Disposition: attachment; filename=\"$(basename "${attachmentFile}")\""
    echo
    base64 < "${attachmentFile}"
    echo
    echo "--${boundary}--"
  } > "${tempMessageFile}"

}

#after the email has been compiled, this function sends the email when passed the gmail API token
sendMimeEmail() {

    #1 : Gmail Access Token - The token that allows us to send the email via the API
    #2 : EML File Location - Where the EML file is stored locally on our computer

    local gmailAccess="$1"
    local emlLocation="$2"

    result=$( curl -X POST \
      -H "Authorization: Bearer $gmailAccess" \
      -H "Content-Type: message/rfc822" \
      --data-binary @$emlLocation \
      "https://gmail.googleapis.com/upload/gmail/v1/users/me/messages/send")


    echo $result

}




####################################MAIN############################################################################################################

#obtain our access token
gmailAccessToken=$( getGmailAPIAuthToken "$refreshToken" "$clientId" "$clientSecret" )

#create the html email, passing the message location; if we had other variables in our email - we could pass them here
createHtmlEmail "$htmlFileLocation"

#now we need to create a MIME email; passing subject, html file location, attachment location, recipient address, and eml file location
createMimeEmail "Hello World - With Attachments!" "$htmlFileLocation" "$fileAttachmentLocation" "user@example.com" "$emlFileLocation"

#now we send the MIME email, passing our auth token as well as the location of the eml file
apiResponse=$( sendMimeEmail "$gmailAccessToken" "$emlFileLocation" )

#see what the response from the API is
echo $apiResponse

#remove the temporary files we created
rm "$htmlFileLocation" 
rm "$emlFileLocation"