#! /bin/zsh

#Getting a refreshed access token

#after you've obtained a refresh token (check setting-up-authorization.sh first), see the function below for getting an access token you can actually use
#NOTE: This assumes you are running macOS version 15+ (older versions of macOS don't have jq installed natively.  If you're on an older version, you can manually install jq)

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

#simply pass your refresh token, client ID, and client secret that we obtained in the setting-up-authorization.sh script
token=$( getGmailAPIAuthToken "INSERT REFRESH TOKEN HERE" "INSERT CLIENT ID HERE" "INSERT CLIENT SECRET HERE" )

echo $token
