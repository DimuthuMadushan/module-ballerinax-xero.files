// Copyright (c) 2026, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/http;

listener http:Listener ep0 = new (9090);

function sampleFile(string id = "3f8a1c52-6a7e-4c1e-9e3b-0d5f0a2b7c11", string name = "invoice-1001.pdf") returns FileObject => {
    createdDateUtc: "2026-03-01T10:15:30",
    updatedDateUtc: "2026-03-02T08:00:00",
    size: 20480,
    id,
    folderId: "b2a9d5c0-1d44-4b0e-8f2a-6c3e91f7a001",
    mimeType: "application/pdf",
    name,
    user: {id: "a1b2c3d4-0000-4000-8000-000000000001", firstName: "Jane", lastName: "Doe", fullName: "Jane Doe", name: "Jane Doe"}
};

function sampleAssociation(string fileId = "3f8a1c52-6a7e-4c1e-9e3b-0d5f0a2b7c11", string objectId = "9c1d2e3f-4a5b-4c6d-8e7f-0a1b2c3d4e5f") returns Association => {
    createdDateUtc: "2026-03-01T10:20:00",
    objectType: "Contact",
    objectId,
    size: 20480,
    objectGroup: "Contact",
    associationDateUtc: "2026-03-01T10:20:00",
    fileId,
    sendWithObject: false,
    name: "invoice-1001.pdf"
};

function sampleFolder(string id = "b2a9d5c0-1d44-4b0e-8f2a-6c3e91f7a001", string name = "Contracts") returns Folder => {
    name,
    fileCount: 4,
    email: "contracts@files.xero.com",
    isInbox: false,
    id
};

service / on ep0 {
    # Deletes a specific file
    #
    # + xeroTenantId - Xero identifier for Tenant
    # + fileId - File id for single object
    # + return - Successful deletion - return response 204 no content 
    resource function delete Files/[string fileId](@http:Header {name: "xero-tenant-id"} string xeroTenantId) returns http:NoContent {
        return http:NO_CONTENT;
    }

    # Deletes an existing file association
    #
    # + xeroTenantId - Xero identifier for Tenant
    # + fileId - File id for single object
    # + objectId - Object id for single object
    # + return - Successful deletion - return response 204 no content 
    resource function delete Files/[string fileId]/Associations/[string objectId](@http:Header {name: "xero-tenant-id"} string xeroTenantId) returns http:NoContent {
        return http:NO_CONTENT;
    }

    # Deletes a folder
    #
    # + xeroTenantId - Xero identifier for Tenant
    # + folderId - Folder id for single object
    # + return - Successful deletion - return response 204 no content 
    resource function delete Folders/[string folderId](@http:Header {name: "xero-tenant-id"} string xeroTenantId) returns http:NoContent {
        return http:NO_CONTENT;
    }

    # Retrieves a count of associations for a list of objects.
    #
    # + xeroTenantId - Xero identifier for Tenant
    # + objectIds - A comma-separated list of object ids
    # + return - Association counts keyed by object ID 
    resource function get Associations/Count(@http:Header {name: "xero-tenant-id"} string xeroTenantId, @http:Query {name: "ObjectIds"} string[] objectIds) returns record {} {
        return {"9c1d2e3f-4a5b-4c6d-8e7f-0a1b2c3d4e5f": 2, "1a2b3c4d-5e6f-4a7b-8c9d-0e1f2a3b4c5d": 1};
    }

    # Retrieves an association object using a unique object ID
    #
    # + xeroTenantId - Xero identifier for Tenant
    # + objectId - Object id for single object
    # + pagesize - pass an optional page size value
    # + page - number of records to skip for pagination
    # + sort - values to sort by
    # + direction - direction to sort by
    # + return - List of associations of the object 
    resource function get Associations/[string objectId](@http:Header {name: "xero-tenant-id"} string xeroTenantId, int? pagesize, int? page, "ASC"|"DESC"? direction, "Name"|"Size"|"CreatedDateUtc"|"AssociationDateUtc" sort = "CreatedDateUtc") returns Association[] {
        return [sampleAssociation(objectId = objectId)];
    }

    # Retrieves files
    #
    # + xeroTenantId - Xero identifier for Tenant
    # + pagesize - pass an optional page size value
    # + page - number of records to skip for pagination
    # + sort - values to sort by
    # + direction - sort direction
    # + return - List of files 
    resource function get Files(@http:Header {name: "xero-tenant-id"} string xeroTenantId, int? pagesize, int? page, "Name"|"Size"|"CreatedDateUTC"? sort, "ASC"|"DESC"? direction) returns FileList {
        return {totalCount: 2, perPage: 50, page: 1, items: [sampleFile(), sampleFile("7d2e9b10-3c58-4f1a-a6d4-5e8f0c1b2a33", "contract-2026.pdf")]};
    }

    # Retrieves a file by a unique file ID
    #
    # + xeroTenantId - Xero identifier for Tenant
    # + fileId - File id for single object
    # + return - The requested file 
    resource function get Files/[string fileId](@http:Header {name: "xero-tenant-id"} string xeroTenantId) returns FileObject {
        return sampleFile(fileId);
    }

    # Retrieves a specific file associations
    #
    # + xeroTenantId - Xero identifier for Tenant
    # + fileId - File id for single object
    # + return - List of associations of the file 
    resource function get Files/[string fileId]/Associations(@http:Header {name: "xero-tenant-id"} string xeroTenantId) returns Association[] {
        return [sampleAssociation(fileId)];
    }

    # Retrieves the content of a specific file
    #
    # + xeroTenantId - Xero identifier for Tenant
    # + fileId - File id for single object
    # + return - Content of the file as a byte array 
    resource function get Files/[string fileId]/Content(@http:Header {name: "xero-tenant-id"} string xeroTenantId) returns byte[] {
        return "sample file content".toBytes();
    }

    # Retrieves folders
    #
    # + xeroTenantId - Xero identifier for Tenant
    # + sort - values to sort by
    # + return - List of folders 
    resource function get Folders(@http:Header {name: "xero-tenant-id"} string xeroTenantId, "Name"|"Size"|"CreatedDateUTC"? sort) returns Folder[] {
        return [sampleFolder(), sampleFolder("c4d5e6f7-1a2b-4c3d-9e8f-7a6b5c4d3e2f", "Receipts")];
    }

    # Retrieves specific folder by using a unique folder ID
    #
    # + xeroTenantId - Xero identifier for Tenant
    # + folderId - Folder id for single object
    # + return - The requested folder 
    resource function get Folders/[string folderId](@http:Header {name: "xero-tenant-id"} string xeroTenantId) returns Folder {
        return sampleFolder(folderId);
    }

    # Retrieves inbox folder
    #
    # + xeroTenantId - Xero identifier for Tenant
    # + return - The inbox folder 
    resource function get Inbox(@http:Header {name: "xero-tenant-id"} string xeroTenantId) returns Folder {
        return {name: "Inbox", fileCount: 3, email: "inbox@files.xero.com", isInbox: true, id: "e1f2a3b4-5c6d-4e7f-8a9b-0c1d2e3f4a5b"};
    }

    # Uploads a File to the inbox
    #
    # + xeroTenantId - Xero identifier for Tenant
    # + idempotencyKey - This allows you to safely retry requests without the risk of duplicate processing. 128 character max
    # + payload - File content and metadata to upload to the inbox 
    # + return - returns can be any of following types 
    # http:Created (File uploaded to the inbox)
    # http:BadRequest (invalid input, object invalid)
    resource function post Files(@http:Header {name: "xero-tenant-id"} string xeroTenantId, @http:Header {name: "Idempotency-Key"} string? idempotencyKey, http:Request request) returns FileObject|JsonBadRequest {
        return sampleFile("5a6b7c8d-9e0f-4a1b-8c2d-3e4f5a6b7c8d", "uploaded-file.pdf");
    }

    # Creates a new file association
    #
    # + xeroTenantId - Xero identifier for Tenant
    # + idempotencyKey - This allows you to safely retry requests without the risk of duplicate processing. 128 character max
    # + fileId - File id for single object
    # + payload - Association linking the file to an object 
    # + return - returns can be any of following types 
    # http:Created (The created file association)
    # http:BadRequest (invalid input, object invalid)
    resource function post Files/[string fileId]/Associations(@http:Header {name: "xero-tenant-id"} string xeroTenantId, @http:Header {name: "Idempotency-Key"} string? idempotencyKey, @http:Payload Association payload) returns Association|JsonBadRequest {
        return sampleAssociation(fileId, payload.objectId ?: "9c1d2e3f-4a5b-4c6d-8e7f-0a1b2c3d4e5f");
    }

    # Uploads a File to a specific folder
    #
    # + xeroTenantId - Xero identifier for Tenant
    # + idempotencyKey - This allows you to safely retry requests without the risk of duplicate processing. 128 character max
    # + folderId - pass required folder id to save file to specific folder
    # + payload - File content and metadata to upload to the folder 
    # + return - returns can be any of following types 
    # http:Created (File uploaded to the folder)
    # http:BadRequest (invalid input, object invalid)
    resource function post Files/[string folderId](@http:Header {name: "xero-tenant-id"} string xeroTenantId, @http:Header {name: "Idempotency-Key"} string? idempotencyKey, http:Request request) returns FileObject|JsonBadRequest {
        FileObject f = sampleFile("6b7c8d9e-0f1a-4b2c-9d3e-4f5a6b7c8d9e", "uploaded-to-folder.pdf");
        f.folderId = folderId;
        return f;
    }

    # Creates a new folder
    #
    # + xeroTenantId - Xero identifier for Tenant
    # + idempotencyKey - This allows you to safely retry requests without the risk of duplicate processing. 128 character max
    # + payload - Properties of the folder to create 
    # + return - returns can be any of following types 
    # http:Ok (The created folder)
    # http:BadRequest (invalid input, object invalid)
    resource function post Folders(@http:Header {name: "xero-tenant-id"} string xeroTenantId, @http:Header {name: "Idempotency-Key"} string? idempotencyKey, @http:Payload Folder payload) returns FolderOk|JsonBadRequest {
        return {body: sampleFolder("d3e4f5a6-7b8c-4d9e-8f0a-1b2c3d4e5f6a", payload.name)};
    }

    # Update a file
    #
    # + xeroTenantId - Xero identifier for Tenant
    # + idempotencyKey - This allows you to safely retry requests without the risk of duplicate processing. 128 character max
    # + fileId - File id for single object
    # + payload - Updated file properties such as name and folder 
    # + return - returns can be any of following types 
    # http:Ok (The updated file)
    # http:BadRequest (invalid input, object invalid)
    resource function put Files/[string fileId](@http:Header {name: "xero-tenant-id"} string xeroTenantId, @http:Header {name: "Idempotency-Key"} string? idempotencyKey, @http:Payload FileObject payload) returns FileObject|JsonBadRequest {
        FileObject f = payload.clone();
        f.id = fileId;
        return f;
    }

    # Updates an existing folder
    #
    # + xeroTenantId - Xero identifier for Tenant
    # + idempotencyKey - This allows you to safely retry requests without the risk of duplicate processing. 128 character max
    # + folderId - Folder id for single object
    # + payload - Updated properties of the folder 
    # + return - returns can be any of following types 
    # http:Ok (The updated folder)
    # http:BadRequest (invalid input, object invalid)
    resource function put Folders/[string folderId](@http:Header {name: "xero-tenant-id"} string xeroTenantId, @http:Header {name: "Idempotency-Key"} string? idempotencyKey, @http:Payload Folder payload) returns Folder|JsonBadRequest {
        return sampleFolder(folderId, payload.name);
    }
}

// Service-mode response types. `bal openapi --mode client` collapses 4XX/5XX
// to `error` and never emits these, so they are defined here for the mock only.
public type FolderOk record {|
    *http:Ok;
    Folder body;
|};

public type JsonBadRequest record {|
    *http:BadRequest;
    json body;
|};
