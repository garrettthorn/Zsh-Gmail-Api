# Sending HTML Emails with Gmail API & Zsh/Bash

In my zsh/bash scripts, I've found that sending emails using ssmtp works, but doesn't allow you the flexibility of sending HTML emails or sending emails with attachments.  The Gmail API allows you to send emails from your Gmail account using the Google Cloud Console.

## Authorization/Authentication
To start, you'll need to set up proper authorization with the Google Cloud Console.  I have steps in the [setting-up-authorization.sh](https://github.com/garrettthorn/Zsh-Gmail-Api/blob/main/setting-up-authorization.sh) file in this repo.  

Once you obtain a refresh token, you'll be able to hardcode these credentials into your script so the script will be able to obtain a new access token each time the script executes.

Of course, storing credentials is plain-text is always a bad idea, even on a hardened machine.  So do this at your own risk.

## Sending HTML Emails
After you've obtained your client ID, client secret, and refresh tokens, you can send a simple HTML email using the [send-html-email.sh](https://github.com/garrettthorn/Zsh-Gmail-Api/blob/main/send-html-email.sh) file in this repo.  This script will save your HTML content to a file at /private/tmp/message.html (by default), and remove the file once it's sent.

## Sending HTML Emails with Attachments
If you'd like to send HTML emails with attachments, you can do that using the MIME format.  Check out the [send-html-email-w-attachments.sh](https://github.com/garrettthorn/Zsh-Gmail-Api/blob/main/send-html-email-w-attachments.sh) file in this repo for more information on doing this.  It's very similar to the standard HTML method, but we just have to create an EML file.

## Notes

 - All my testing was done on macOS 15+
	 - jq is referenced in a few of the scripts; which is natively installed in macOS 15, but not in earlier versions
 - I got a lot of my information from [this article](https://sysopstechnix.com/insert-data-into-google-sheets-via-oauth-2-0-using-shell-script/) on setting up all the authorization stuff.  This is for Google Sheets, but it's basically the same thing.
