# Ballerina Xero Files connector

[![Build](https://github.com/ballerina-platform/module-ballerinax-xero.files/actions/workflows/ci.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-xero.files/actions/workflows/ci.yml)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-xero.files.svg)](https://github.com/ballerina-platform/module-ballerinax-xero.files/commits/main)
[![GitHub Issues](https://img.shields.io/github/issues/ballerina-platform/ballerina-library/module/xero.files.svg?label=Open%20Issues)](https://github.com/ballerina-platform/ballerina-library/labels/module%2Fxero.files)

## Overview

[Xero](https://www.xero.com/) is a cloud accounting platform for small and medium-sized businesses. The [Xero Files API](https://developer.xero.com/documentation/api/files/overview) lets applications store documents in an organisation's Xero file library, organise them into folders and link them to accounting records such as invoices, contacts and bank transactions.

The Xero Files connector lets Ballerina applications upload, download and organise files and folders, and manage the associations between files and Xero objects. It supports version 1.0 of the Xero Files API.

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

1. Direct the user to the authorization URL, replacing `YOUR_CLIENT_ID` and `YOUR_REDIRECT_URI`. Request the `files` scope for read and write access to files and folders (or `files.read` for read-only access) and `offline_access` to receive a refresh token.

```
https://login.xero.com/identity/connect/authorize?response_type=code&client_id=YOUR_CLIENT_ID&redirect_uri=YOUR_REDIRECT_URI&scope=offline_access files
```

2. After the user authorizes the app, Xero redirects to your redirect URI with an authorization code.

3. Exchange the code for tokens.

```curl
curl -X POST https://identity.xero.com/connect/token \
  -H "Authorization: Basic $(echo -n 'CLIENT_ID:CLIENT_SECRET' | base64)" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=authorization_code&code=AUTHORIZATION_CODE&redirect_uri=YOUR_REDIRECT_URI"
```

The response contains an `access_token` and a `refresh_token`.

### Step 4: Find your tenant ID

Every Files API call needs the ID of the Xero organisation to work with, sent in the `xero-tenant-id` header. List the organisations the user has connected.

```curl
curl -X GET https://api.xero.com/connections \
  -H "Authorization: Bearer ACCESS_TOKEN"
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

1. [Invoice document filing](examples/invoice_document_filing) - Create a folder, upload a supporting document into it, link the document to an invoice and confirm the link.

2. [Inbox file triage](examples/inbox_file_triage) - Page through all files, pick out those still in the Xero inbox and move them into a target folder.

## Build from the source

### Setting up the prerequisites

1. Download and install Java SE Development Kit (JDK) version 21. You can download it from either of the following sources:

    * [Oracle JDK](https://www.oracle.com/java/technologies/downloads/)
    * [OpenJDK](https://adoptium.net/)

   > **Note:** After installation, remember to set the `JAVA_HOME` environment variable to the directory where JDK was installed.

2. Download and install [Ballerina Swan Lake](https://ballerina.io/).

3. Download and install [Docker](https://www.docker.com/get-started).

   > **Note**: Ensure that the Docker daemon is running before executing any tests.

4. Export Github Personal access token with read package permissions as follows,

    ```bash
    export packageUser=<Username>
    export packagePAT=<Personal access token>
    ```

### Build options

Execute the commands below to build from the source.

1. To build the package:

   ```bash
   ./gradlew clean build
   ```

2. To run the tests:

   ```bash
   ./gradlew clean test
   ```

3. To build the without the tests:

   ```bash
   ./gradlew clean build -x test
   ```

4. To run tests against different environments:

   ```bash
   ./gradlew clean test -Pgroups=<Comma separated groups/test cases>
   ```

5. To debug the package with a remote debugger:

   ```bash
   ./gradlew clean build -Pdebug=<port>
   ```

6. To debug with the Ballerina language:

   ```bash
   ./gradlew clean build -PbalJavaDebug=<port>
   ```

7. Publish the generated artifacts to the local Ballerina Central repository:

    ```bash
    ./gradlew clean build -PpublishToLocalCentral=true
    ```

8. Publish the generated artifacts to the Ballerina Central repository:

   ```bash
   ./gradlew clean build -PpublishToCentral=true
   ```

## Contribute to Ballerina

As an open-source project, Ballerina welcomes contributions from the community.

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct

All the contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful links

* For more information go to the [`xero.files` package](https://central.ballerina.io/ballerinax/xero.files/latest).
* For example demonstrations of the usage, go to [Ballerina By Examples](https://ballerina.io/learn/by-example/).
* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.
