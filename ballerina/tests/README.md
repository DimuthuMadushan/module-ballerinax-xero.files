# Running Tests

## Prerequisites

To run the tests against the live Xero Files API you need a Xero app, an access token with the `files` scope and the ID of the Xero organisation (tenant) to test against. Follow the [Setup guide](https://github.com/ballerina-platform/module-ballerinax-xero.files/blob/main/ballerina/README.md#setup-guide) to obtain them.

## Test environments

There are two test environments. The default is a mock server that implements the Xero Files API. The other is the live Xero Files API.

 Test Groups | Environment
-------------|------------------------------------------------
 mock_tests  | Mock server for the Xero Files API (default)
 live_tests  | Xero Files API (read-only operations)

## Running the tests

### Mock server

Run the tests against the mock server:

```bash
bal test --groups mock_tests
```

### Live API

Set the following environment variables and run the live tests:

```bash
export IS_LIVE_SERVER=true
export XERO_ACCESS_TOKEN="<access-token>"
export XERO_TENANT_ID="<xero-tenant-id>"
bal test --groups live_tests
```

The live tests only read data. The read operations assume the organisation already has at least one file, a folder and an association.
