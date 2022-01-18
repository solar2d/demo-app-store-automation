# Solar2D → AppStore; macOS not needed

All you need is a web browser (sic).

The whole setup should take about 20 minutes. I tried to write as much detail as possible so do not be daunted by the size of this guide, it's just very detailed to make the process easier.

# Prerequisites

- Apple account with active [Apple Development Program](http://developer.apple.com/account/) subscription, enrolled as individual or part of a team
- GitHub account
- Google account
- iOS Device with [TestFlight](https://itunes.apple.com/us/app/testflight/id899247664?mt=8) installed for testing

# General overview

Here is a quick summary of what we are about to do:

- Clone the GitHub repository and set it up
- Generate Apple signing credentials and replace placeholders in the repo

### 1. Preparing the repo

1. Log in to [GitHub](http://github.com/) and press the ➕ button in the top right corner, then select "Import repository". We import the repository instead of forking it so that there's an option to set your repository to private. GitHub forks of public repositories can only be set to public. [⏯](https://i.imgur.com/btddTj3.gif)
2. Paste the clone url: `https://github.com/solar2d/demo-app-store-automation.git`, pick a name for your repo, (e.g. "Solar2Demo"), and choose a visibility. This particular project does not contain any unencrypted sensitive information but if you plan to extend it, make it private. You can change the visibility later.
3. In your repo press "⚙ Settings" in the menu bar and pick "Secrets" in the sidebar.
4. Skip to the [next section](#2-creating-an-app-id) if doing FTP upload instead of app store deployment
5. Press "<a name="secret-create">New Repository Secret</a>" and type the following Name and Value pairs into their corresponding fields, clicking "Add secret" for each. [⏯](https://i.imgur.com/yLcgLO6.gif):
    1. Name: `AppleUser`</br>
       Value: Your Apple ID user email.
    2. Name: `ApplePassword`</br>
       Value: Your Apple ID password. Most likely you have two-factor authentication set up, in which case don't use your actual password; Head to [https://appleid.apple.com/](https://appleid.apple.com/account/manage) and log in, generate an "app-specific password" to use instead.
6. If your Apple Account is enrolled in the development program as part of a team then you have to specify an `AppleTeamId` secret. This step is otherwise optional. [⏯](https://i.imgur.com/QEvOSJo.gif)
    1. Click on "Actions" in the menu bar and select "List Apple Teams" from the sidebar.
    2. Click on the "Run Workflow" button and confirm by clicking the green button.
    3. Wait a moment for the workflow to appear on the list. After some time, the symbol next to it should become a check mark ✓. Click on "List Apple Teams" near the check mark.
    4. Click "list" in the sidebar and then "List Teams" from the main page area. This should expand an ASCII table.
    5. Locate the desired team short name from the ProviderShortname column and save it as `AppleTeamId` in "Settings" → "Secrets".
    6. This action log can contain some sensitive information, such as your name, accessible by anyone who has access to the repo, so I recommend deleting it. To do that, head back to the Actions tab and in the main page area click on the ⋯ button next to "List Apple Teams". Run and select "Delete workflow run". [⏯](https://i.imgur.com/KSyEKI7.gif)
7. You may want to edit your app name. For that:
    1. Click on "Code" in the menu bar, and navigate to the "Util" directory.
    2. Click on the "recipe.lua" file and then the ✎ pencil button to edit it.
    3. Change the name in quotes, (currently "Solar2Demo"), in the editor and click the "Commit changes" button to save the file.
    4. I would strongly advise against using anything but basic English letters, or changing anything else in this file, unless you are very certain of what you are doing.

### 2. Creating an App ID

1. Log in to the Apple Developer Web Portal: [http://developer.apple.com/account/](http://developer.apple.com/account/)
2. Select "Certificates, Identifiers & Profiles".
3. In the sidebar, select "Identifiers" and click ➕ to create one.
4. You want to create an "App ID" of the type "App".
5. Fill out the form for this app:
    1. Description: Something you will recognize your app by, e.g. `Solar2D Demo App`.
    2. App prefix: I usually select one which says "Team ID", but it doesn't matter much.
    3. Explicit bundle id: e.g. `com.solar2d.solar2demo`. You would have to change the company name to something else since this must be unique.
    4. Default capabilities usually work just fine. You can edit them later.

### 3. Creating a signing certificate

Apple requires applications to be cryptographically signed. To do that you need two things: certificate and provisioning profile. Certificate identify your team and created created per account (same certificate is shared for all your projects). Xcode automates this process, but we will instead use command line utilities provided for free by Google Cloud Shell. [⏯](https://i.imgur.com/6BoMPFi.mp4)

1. Follow this: [link](https://shell.cloud.google.com/?hl=en_US&fromcloudshell=true&show=terminal). It should open a new terminal session for you.
2. Run: `rm -f key.key distribution*; openssl req -newkey rsa:2048 -keyout key.key -out request.csr -nodes -subj "/C=CA/ST=/L=/O=/CN=Solar2D"; cloudshell dl request.csr`
3. This should prompt downloading a "request.csr" file. Accept it and do not close the terminal, you'll need it again in a minute.
4. In the [Apple Developer](https://developer.apple.com/account/resources/certificates/list) portal, go to "Certificates" → "IDs & Profiles" → "Certificates".
5. Hit the ➕ button to start the process of creating a certificate.
6. Select "Apple Distribution".
7. Hit "Choose File" and select the "request.csr" file we just downloaded.
8. Hit "Create" and then "Download" to get the "distribution.cer" certificate file.
9. Return to the Cloud Shell window and upload the certificate. You can do this by dragging and dropping the "distribution.cer" file to the console or by selecting it via "Upload Files" in the ⋮ (More) menu.
10. Run: `openssl x509 -inform DER -in distribution.cer -out distribution.crt && openssl pkcs12 -export -out distribution.p12 -inkey key.key -in distribution.crt && cloudshell dl distribution.p12 && rm -f key.key request.csr distribution.c*`
11. When prompted for a password I suggest using a strong [randomly generated password](https://passwordsgenerator.net/?length=22&symbols=0&numbers=1&lowercase=1&uppercase=1&similar=0&ambiguous=0&client=1&autoselect=1).
12. Save the password in your GitHub repo as `CertPassword` secret, (we added other secrets in the [previous](#secret-create) section). You will also need this password if you decide to use an actual Mac and import the certificate there.
13. Accept the p12 bundle, containing encrypted signing certificates.
14. In your GitHub repo, navigate to "Code", then click on the "Util" directory.
15. Press the "Add file" button and select "Upload files".
16. Select the downloaded "distribution.p12" file and click the "Commit changes" button.

In your next project jump right to step 12 and reuse this password and `distribution.p12` file.

### 4. Creating a provisioning profile

Second part involved in signing is a provisioning profile. It identifies your application and its capabilities, so it has to be created for each project individually.

1. Head to [Developer Portal](https://developer.apple.com/account/resources/profiles/list), select "Profiles" and click ➕ to create one.
2. Select "App Store" from the Distribution section.
3. Select the app ID we created earlier, ("com.solar2d.solar2demo" in my case).
4. On the next page select the certificate we just created. If you have multiple then pick one with an expiry date exactly one year forward.
5. On the next page type in the name "distribution" and hit "Generate".
6. Download the generated profile. If your file is named differently, make sure you rename it to `distribution.mobileprovision` as the build script expects the file to be named as such.
7. Upload the file to replace a placeholder in the "Util" directory of your GitHub repository, as per the end of the previous section.

### 5. Creating an App listing

We have to create an App listing in order to upload and test the app. If you would rather upload the ipa to an ftp server got to section [Setting up FTP upload](#setting-up-ftp-upload) and skip the next few sections.

1. Head to the App Store Connect website: [https://appstoreconnect.apple.com/](https://appstoreconnect.apple.com/)
2. Log in, read, and accept any user agreements.
3. Select "My Apps".
4. In the menu near "Apps" click the ➕ button and select "New App".
5. In the popup:
    1. Select iOS as the platform.
    2. Name your app, e.g. "Solar2Demo".
    3. Choose a language, e.g. "English (U.S.)".
    4. Set the Bundle ID we created previously. For me it is "Solar2D Demo App - com.solar2d.solar2demo".
    5. Set an SKU to identify the app for yourself, e.g. "Solar2Demo".
    6. Select "Full Access" and click "Create".
6. After a few moments you will have the App listing page.
7. You will need this browser window later to set up testers, so keep it around.

## Quick check-up

When all is done you should have the following:

- 4 Secrets in GitHub repository settings [⏯](https://i.imgur.com/zB92Fjr.png):
    - [x] `AppleUser`
    - [x] `ApplePassword`
    - [x] `AppleTeamId` *(Optional)*
    - [x] `CertPassword`
- 2 files replaced in `Util` directory [⏯](https://i.imgur.com/6b9xcZS.png):
    - [x] `Util/distribution.p12`
    - [x] `Util/distribution.mobileprovision`

# Building and uploading the App

Now for the fun part; Building and uploading the app:

1. Navigate to your GitHub repo and select "Actions" from the menu bar.
2. Select "Build and Deliver" in the workflows sidebar.
3. Select "Run Workflow", leave all parameters as default and confirm by pressing the green button.

Done!

This will start a build. It should succeed in about 3-10 minutes, but it will also upload the built app to the App Store Connect, where it will undergo automatic processing. This may take some time.

## Testing your app

Right after the GitHub action submitted a build, you can set up testing. To do that:

1. Head back to the [App Store Connect](https://appstoreconnect.apple.com/) portal, and navigate to your app in "My Apps".
2. In the top menu select "TestFlight" and then select "App Store Connect Users" in the sidebar under the "Internal Group" section.
3. Hit ➕ near "Testers" and add at least yourself. This will send you an email.
4. You have to open this email on your iOS device and click the button in it. The TestFlight app should open and prompt you to accept app testing.

When the build process is complete, you will get an email and/or push notification with a status update. Use TestFlight on the device to install your app and test it.

### Consecutive builds

With repository and TestFlight already set up, all you have to do is push your code, navigate to "Build and Deliver" in your repo Actions, and run the workflow.

Then wait for a notification and use TestFlight to get the update.

# Setting up FTP upload

The ipa is upload using this command `curl -T Util/$fileName ${FTP_URL}/$(date +%Y-%m-%dT%H:%M:%S)-$fileName --user ${FTP_USER}` notice the / after the `${FTP_URL}` variable and the `${FTP_USER}` as the --user argument.

1. Press New Repository Secret and type the following Name and Value pairs into their corresponding fields, clicking "Add secret" for each. [⏯](https://i.imgur.com/yLcgLO6.gif):
    1. Name: `FTPURL`</br>
       Value: Your FTP server URL. Eg. `ftp://your-ftp-server.com/coron-builds/project`
       Notice the inclusion of the sub folder and the lack of trailing slash
    2. Name: `FTPUser`</br>
       Value: The argument to pass to the upload command. Eg. `client-id:client-secret`


## Quick check-up

When all is done you should have the following to properly do ftp upload:

- 4 Secrets in GitHub repository settings [⏯](https://i.imgur.com/zB92Fjr.png):
    - [x] `FTPURL`
    - [x] `FTPUser`
    - [x] `CertPassword`
- 2 files replaced in `Util` directory [⏯](https://i.imgur.com/6b9xcZS.png):
    - [x] `Util/distribution.p12`
    - [x] `Util/distribution.mobileprovision`

# What's next

Replace the project in the "Project" directory with your creation. Clone the repository to your computer, replace or modify contents, commit changes, and make new builds. When the update is ready, update your app with TestFlight.

Another option is to modify scripts and integrate them into your existing projects hosted on GitHub. Check out [`.github/workflows/build.yml`](.github/workflows/build.yml) and [`Util/build.sh`](Util/build.sh) for that.

## Show some love ❤️ (free)

If you enjoyed this template and guide, make sure you "Star" these projects on GitHub:

- Solar2D Game Engine: [https://github.com/coronalabs/corona](https://github.com/coronalabs/corona)
- This template: [https://github.com/solar2d/demo-app-store-automation](https://github.com/solar2d/demo-app-store-automation)

## Support the project

Solar2D is a fully open source game engine which relies on user donations to exist. Consider [supporting](http://github.com/coronalabs/corona?sponsor=1) the project on [Patreon](https://patreon.com/shchvova).

### Side notes

GitHub Actions has [usage limits](https://docs.github.com/en/free-pro-team@latest/github/setting-up-and-managing-billing-and-payments-on-github/about-billing-for-github-actions), especially for private repositories, so make sure you check them out. Today free users get 200 macOS minutes and incur costs of ¢8/minute over that limit. This is more than enough for pushing a build once or twice a week. You don't have to set up billing details until you run out of free minutes, and even then it is hard to beat their pricing.

## Questions/Issues

If you have any questions report them to [https://github.com/solar2d/demo-app-store-automation/issues](https://github.com/solar2d/demo-app-store-automation/issues).

Enjoy and create some awesome Solar2D games!

![Solar2D Logo](https://solar2d.com/images/icon-180x180.png)
