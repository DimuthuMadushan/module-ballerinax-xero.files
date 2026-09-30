# Inbox file triage

This example clears the Xero inbox. It reads the inbox folder, pages through all files and picks out those still in the inbox, then moves each one into a target folder. By default it only reports what it would move; set `applyChanges` to `true` to move the files.

## Prerequisites

### 1. Set up a Xero app

Follow the [Setup guide](https://github.com/ballerina-platform/module-ballerinax-xero.files/blob/main/ballerina/README.md#setup-guide) to obtain a client ID, client secret and refresh token. The app needs the `files` scope, and you need the ID of the Xero organisation (tenant) to work with.

### 2. Configuration

Create a `Config.toml` file in this example's directory with the following content:

```toml
clientId = "<client-id>"
clientSecret = "<client-secret>"
refreshToken = "<refresh-token>"
tenantId = "<xero-tenant-id>"
targetFolderId = "<destination-folder-id>"
pageSize = 50
applyChanges = false
```

## Run the example

Execute the following command to run the example:

```bash
bal run
```
