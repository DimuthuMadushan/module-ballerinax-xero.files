## Overview

[Xero](https://www.xero.com/) is a cloud accounting platform for small and medium-sized businesses. The [Xero Files API](https://developer.xero.com/documentation/api/files/overview) lets applications store documents in an organisation's Xero file library, organise them into folders and link them to accounting records such as invoices, contacts and bank transactions.

The Xero Files connector lets Ballerina applications upload, download and organise files and folders, and manage the associations between files and Xero objects. It supports version 1.0 of the Xero Files API.

### Key features

- Upload files to the inbox or to a specific folder and download their content
- Create, update and delete folders and read the inbox folder
- Update file properties and delete files
- Link files to Xero objects such as invoices, contacts and credit notes
- Look up the files linked to an object and count associations for many objects at once


## Setup guide

To use the Xero Files connector, you need a Xero account and an OAuth 2.0 app in the [Xero developer portal](https://developer.xero.com/app/manage). If you do not have a Xero account, you can sign up for one [here](https://www.xero.com/signup/).

### Step 1: Create an app

1. Open the [Xero developer portal](https://developer.xero.com/app/manage) and sign in.

2. Click **New app**, give it a name, choose the **Web app** integration type, and enter your company URL and a redirect URI (for example, `http://localhost:8080/callback`).

3. Accept the terms and create the app.

### Step 2: Get the client credentials

1. Open the app and go to the **Configuration** tab.

2. Copy the **Client id** and generate a **Client secret**. Copy the secret immediately, because Xero shows it only once.

### Step 3: Get a refresh token

1. Direct the user to the authorization URL, replacing `YOUR_CLIENT_ID`, `YOUR_REDIRECT_URI` and `YOUR_STATE`. `YOUR_STATE` must be a unique, unguessable value generated for each authorization request (for example, with `openssl rand -hex 16`) and stored with the user's session. Request the `files` scope for read and write access to files and folders (or `files.read` for read-only access) and `offline_access` to receive a refresh token.

```
https://login.xero.com/identity/connect/authorize?response_type=code&client_id=YOUR_CLIENT_ID&redirect_uri=YOUR_REDIRECT_URI&scope=offline_access files&state=YOUR_STATE
```

2. After the user authorizes the app, Xero redirects to your redirect URI with an authorization code and the `state` value. Before you use the code, check that `state` matches the value you stored for this request, and reject the callback if it does not.

3. Exchange the code for tokens. The following reads the client credentials and the authorization code without echoing them, and passes them to `curl` on standard input so they do not appear in the command line or the shell history. Replace `YOUR_REDIRECT_URI`.

```bash
printf 'Client ID: '; read -r CLIENT_ID
printf 'Client secret: '; read -rs CLIENT_SECRET; echo
printf 'Authorization code: '; read -rs AUTHORIZATION_CODE; echo

printf 'header = "Authorization: Basic %s"\ndata = "grant_type=authorization_code&code=%s&redirect_uri=YOUR_REDIRECT_URI"\n' \
  "$(printf '%s:%s' "$CLIENT_ID" "$CLIENT_SECRET" | base64 | tr -d '\n')" "$AUTHORIZATION_CODE" |
  curl -X POST https://identity.xero.com/connect/token \
    -H "Content-Type: application/x-www-form-urlencoded" -K -
```

The response contains an `access_token` and a `refresh_token`.

### Step 4: Find your tenant ID

Every Files API call needs the ID of the Xero organisation to work with, sent in the `xero-tenant-id` header. List the organisations the user has connected.

```bash
printf 'Access token: '; read -rs ACCESS_TOKEN; echo

printf 'header = "Authorization: Bearer %s"\n' "$ACCESS_TOKEN" |
  curl -X GET https://api.xero.com/connections -K -
```

Use the `tenantId` of the organisation you want to work with.

## Quickstart

To use the Xero Files connector in your Ballerina application, update the `.bal` file as follows.

### Step 1: Import the module

Import the `ballerinax/xero.files` module.

```ballerina
import ballerinax/xero.files;
```

### Step 2: Instantiate a new connector

Create a `Config.toml` file with your credentials.

```toml
clientId = "<client-id>"
clientSecret = "<client-secret>"
refreshToken = "<refresh-token>"
tenantId = "<xero-tenant-id>"
```

Then create a `files:Client` using them.

```ballerina
configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;
configurable string tenantId = ?;

final files:Client xeroFiles = check new ({
    auth: {clientId, clientSecret, refreshToken}
});
```

### Step 3: Invoke the connector operation

Use the client to call an operation. The following lists the folders in the organisation.

```ballerina
public function main() returns error? {
    files:Folder[] _ = check xeroFiles->listFolders({xeroTenantId: tenantId});
}
```

### Step 4: Run the Ballerina application

```bash
bal run
```

## Examples

The `Xero Files` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/ballerina-platform/module-ballerinax-xero.files/tree/main/examples/), covering the following use cases:

1. [Invoice document filing](../examples/invoice_document_filing) - Create a folder, upload a supporting document into it, link the document to an invoice and confirm the link.

2. [Inbox file triage](../examples/inbox_file_triage) - Page through all files, pick out those still in the Xero inbox and move them into a target folder.
