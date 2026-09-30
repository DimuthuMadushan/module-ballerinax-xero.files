# Examples

The `ballerinax/xero.files` connector provides practical examples illustrating usage in various scenarios.

1. **[Invoice document filing](https://github.com/ballerina-platform/module-ballerinax-xero.files/tree/main/examples/invoice_document_filing)** - Create a folder, upload a supporting document into it, link the document to an invoice and confirm the link.

2. **[Inbox file triage](https://github.com/ballerina-platform/module-ballerinax-xero.files/tree/main/examples/inbox_file_triage)** - Page through all files, pick out those still in the Xero inbox and move them into a target folder.

## Prerequisites

1. Generate Xero credentials to authenticate the connector as described in the [Setup guide](https://central.ballerina.io/ballerinax/xero.files/latest#setup-guide).

2. For each example, create a `Config.toml` file with the related configuration. Here's an example of how your Config.toml file should look:

```toml
clientId = "<client-id>"
clientSecret = "<client-secret>"
refreshToken = "<refresh-token>"
tenantId = "<xero-tenant-id>"
```

Each example lists the additional values it needs in its own README.

## Running an example

Execute the following commands to build an example from the source:

* To build an example:

    ```bash
    bal build
    ```

* To run an example:

    ```bash
    bal run
    ```
