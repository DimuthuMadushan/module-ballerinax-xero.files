# Invoice document filing

This example files a supporting document for an invoice. It creates a folder, uploads the document into it, links the uploaded file to the invoice and lists the file's associations to confirm the link.

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
folderName = "<folder-name, e.g. Supplier invoices>"
invoiceId = "<invoice-id>"
documentName = "<file-name, e.g. invoice-1001.pdf>"
documentPath = "<path-to-the-file, e.g. ./invoice-1001.pdf>"
documentMimeType = "application/pdf"
```

## Run the example

Execute the following command to run the example:

```bash
bal run
```
