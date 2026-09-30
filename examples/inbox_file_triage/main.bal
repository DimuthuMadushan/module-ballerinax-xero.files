// Moves files waiting in the Xero inbox into a chosen folder. Nothing is changed
// unless applyChanges is set to true.

import ballerina/io;
import ballerinax/xero.files;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;
configurable string tenantId = ?;
configurable string targetFolderId = ?;
configurable int pageSize = 50;
configurable boolean applyChanges = false;

public function main() returns error? {
    files:Client xeroFiles = check new ({
        auth: {clientId, clientSecret, refreshToken}
    });

    files:Folder inbox = check xeroFiles->getInbox({xeroTenantId: tenantId});
    string? inboxId = inbox.id;
    if inboxId is () {
        return error("Xero did not return an id for the inbox");
    }
    io:println("Inbox holds ", inbox.fileCount ?: 0, " file(s)");

    files:FileObject[] waiting = [];
    int page = 1;
    while true {
        files:FileList result = check xeroFiles->listFiles({xeroTenantId: tenantId}, {pagesize: pageSize, page, sort: "CreatedDateUTC", direction: "ASC"});
        files:FileObject[] items = result.items ?: [];
        foreach files:FileObject item in items {
            if item.folderId == inboxId {
                waiting.push(item);
            }
        }
        if items.length() < pageSize {
            break;
        }
        page += 1;
    }
    io:println("Found ", waiting.length(), " file(s) waiting in the inbox");

    foreach files:FileObject item in waiting {
        string? fileId = item.id;
        if fileId is () {
            continue;
        }
        if !applyChanges {
            io:println("Would move ", item.name ?: fileId, " to folder ", targetFolderId);
            continue;
        }
        files:FileObject moved = check xeroFiles->updateFile(fileId, {xeroTenantId: tenantId}, {name: item.name, folderId: targetFolderId});
        io:println("Moved ", moved.name ?: fileId, " to folder ", moved.folderId ?: targetFolderId);
    }
}
