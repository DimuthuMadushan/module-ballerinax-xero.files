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
import ballerina/os;
import ballerina/test;

final boolean isLiveServer = os:getEnv("IS_LIVE_SERVER") == "true";
final string serviceUrl = isLiveServer ? "https://api.xero.com/files.xro/1.0/" : "http://localhost:9090";
final string token = isLiveServer ? os:getEnv("XERO_ACCESS_TOKEN") : "test_token";
final string tenantId = isLiveServer ? os:getEnv("XERO_TENANT_ID") : "test-tenant-id";

final Client xeroFiles = check new ({
    auth: {token},
    httpVersion: isLiveServer ? http:HTTP_2_0 : http:HTTP_1_1
}, serviceUrl);

const string SAMPLE_FILE_ID = "3f8a1c52-6a7e-4c1e-9e3b-0d5f0a2b7c11";
const string SAMPLE_FOLDER_ID = "b2a9d5c0-1d44-4b0e-8f2a-6c3e91f7a001";
const string SAMPLE_OBJECT_ID = "9c1d2e3f-4a5b-4c6d-8e7f-0a1b2c3d4e5f";

// Live tests read the IDs from XERO_FILE_ID, XERO_FOLDER_ID and XERO_OBJECT_ID, or look
// them up in the tenant when those are not set. Mock tests use the sample IDs.
function liveFileId() returns string|error {
    if !isLiveServer {
        return SAMPLE_FILE_ID;
    }
    string configured = os:getEnv("XERO_FILE_ID");
    if configured != "" {
        return configured;
    }
    FileList files = check xeroFiles->listFiles({xeroTenantId: tenantId}, {pagesize: 1});
    FileObject[] items = files.items ?: [];
    string? id = items.length() > 0 ? items[0].id : ();
    return id ?: error("The tenant has no files; set XERO_FILE_ID");
}

function liveFolderId() returns string|error {
    if !isLiveServer {
        return SAMPLE_FOLDER_ID;
    }
    string configured = os:getEnv("XERO_FOLDER_ID");
    if configured != "" {
        return configured;
    }
    Folder[] folders = check xeroFiles->listFolders({xeroTenantId: tenantId});
    string? id = folders.length() > 0 ? folders[0].id : ();
    return id ?: error("The tenant has no folders; set XERO_FOLDER_ID");
}

function liveObjectId() returns string|error {
    if !isLiveServer {
        return SAMPLE_OBJECT_ID;
    }
    string configured = os:getEnv("XERO_OBJECT_ID");
    if configured != "" {
        return configured;
    }
    Association[] associations = check xeroFiles->listFileAssociations(check liveFileId(), {xeroTenantId: tenantId});
    string? id = associations.length() > 0 ? associations[0].objectId : ();
    return id ?: error("The file has no associations; set XERO_OBJECT_ID");
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testListFiles() returns error? {
    FileList response = check xeroFiles->listFiles({xeroTenantId: tenantId});
    test:assertTrue(response.items is FileObject[]);
    test:assertTrue((response.items ?: []).length() > 0);
}

@test:Config {groups: ["mock_tests"]}
function testUploadFile() returns error? {
    FileObject response = check xeroFiles->uploadFile({xeroTenantId: tenantId}, {
        filename: "uploaded-file.pdf",
        name: "uploaded-file.pdf",
        mimeType: "application/pdf",
        body: {fileContent: "sample file content".toBytes(), fileName: "uploaded-file.pdf"}
    });
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testGetFile() returns error? {
    FileObject response = check xeroFiles->getFile(check liveFileId(), {xeroTenantId: tenantId});
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
function testUpdateFile() returns error? {
    FileObject response = check xeroFiles->updateFile(SAMPLE_FILE_ID, {xeroTenantId: tenantId}, {name: "renamed.pdf", folderId: SAMPLE_FOLDER_ID});
    test:assertEquals(response.id, SAMPLE_FILE_ID);
}

@test:Config {groups: ["mock_tests"]}
function testDeleteFile() returns error? {
    Folder folder = check xeroFiles->createFolder({xeroTenantId: tenantId}, {name: "Delete file test"});
    FileObject created = check xeroFiles->uploadFileToFolder(folder.id ?: SAMPLE_FOLDER_ID, {xeroTenantId: tenantId}, {
        filename: "to-delete.pdf",
        name: "to-delete.pdf",
        mimeType: "application/pdf",
        body: {fileContent: "sample file content".toBytes(), fileName: "to-delete.pdf"}
    });
    error? response = xeroFiles->deleteFile(created.id ?: SAMPLE_FILE_ID, {xeroTenantId: tenantId});
    test:assertTrue(response is ());
}

@test:Config {groups: ["mock_tests"]}
function testUploadFileToFolder() returns error? {
    FileObject response = check xeroFiles->uploadFileToFolder(SAMPLE_FOLDER_ID, {xeroTenantId: tenantId}, {
        filename: "uploaded-to-folder.pdf",
        name: "uploaded-to-folder.pdf",
        mimeType: "application/pdf",
        body: {fileContent: "sample file content".toBytes(), fileName: "uploaded-to-folder.pdf"}
    });
    test:assertEquals(response.folderId, SAMPLE_FOLDER_ID);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testGetFileContent() returns error? {
    byte[] response = check xeroFiles->getFileContent(check liveFileId(), {xeroTenantId: tenantId});
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testListFileAssociations() returns error? {
    Association[] response = check xeroFiles->listFileAssociations(check liveFileId(), {xeroTenantId: tenantId});
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
function testCreateFileAssociation() returns error? {
    Association response = check xeroFiles->createFileAssociation(SAMPLE_FILE_ID, {xeroTenantId: tenantId}, {objectId: SAMPLE_OBJECT_ID, objectGroup: "Contact"});
    test:assertEquals(response.objectId, SAMPLE_OBJECT_ID);
}

@test:Config {groups: ["mock_tests"]}
function testDeleteFileAssociation() returns error? {
    Association created = check xeroFiles->createFileAssociation(SAMPLE_FILE_ID, {xeroTenantId: tenantId}, {objectId: SAMPLE_OBJECT_ID, objectGroup: "Contact"});
    error? response = xeroFiles->deleteFileAssociation(SAMPLE_FILE_ID, created.objectId ?: SAMPLE_OBJECT_ID, {xeroTenantId: tenantId});
    test:assertTrue(response is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testListObjectAssociations() returns error? {
    Association[] response = check xeroFiles->listObjectAssociations(check liveObjectId(), {xeroTenantId: tenantId});
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testCountAssociations() returns error? {
    record {} response = check xeroFiles->countAssociations({xeroTenantId: tenantId}, {objectIds: [check liveObjectId()]});
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testListFolders() returns error? {
    Folder[] response = check xeroFiles->listFolders({xeroTenantId: tenantId});
    test:assertTrue(response.length() > 0);
}

@test:Config {groups: ["mock_tests"]}
function testCreateFolder() returns error? {
    Folder response = check xeroFiles->createFolder({xeroTenantId: tenantId}, {name: "Invoices"});
    test:assertEquals(response.name, "Invoices");
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testGetFolder() returns error? {
    Folder response = check xeroFiles->getFolder(check liveFolderId(), {xeroTenantId: tenantId});
    test:assertTrue(response.id is string);
}

@test:Config {groups: ["mock_tests"]}
function testUpdateFolder() returns error? {
    Folder response = check xeroFiles->updateFolder(SAMPLE_FOLDER_ID, {xeroTenantId: tenantId}, {name: "Archive"});
    test:assertEquals(response.name, "Archive");
}

@test:Config {groups: ["mock_tests"]}
function testDeleteFolder() returns error? {
    Folder created = check xeroFiles->createFolder({xeroTenantId: tenantId}, {name: "To delete"});
    error? response = xeroFiles->deleteFolder(created.id ?: SAMPLE_FOLDER_ID, {xeroTenantId: tenantId});
    test:assertTrue(response is ());
}

@test:Config {groups: ["live_tests", "mock_tests"]}
function testGetInbox() returns error? {
    Folder response = check xeroFiles->getInbox({xeroTenantId: tenantId});
    test:assertEquals(response.isInbox, true);
}
