// Files a document for an invoice: creates a folder, uploads the document into it,
// links the document to the invoice and lists the links back to confirm.

import ballerina/io;
import ballerinax/xero.files;

configurable string clientId = ?;
configurable string clientSecret = ?;
configurable string refreshToken = ?;
configurable string tenantId = ?;
configurable string folderName = ?;
configurable string invoiceId = ?;
configurable string documentName = ?;
configurable string documentBase64 = ?;
configurable string documentMimeType = "application/pdf";

public function main() returns error? {
    files:Client xeroFiles = check new ({
        auth: {clientId, clientSecret, refreshToken}
    });

    files:Folder folder = check xeroFiles->createFolder({xeroTenantId: tenantId}, {Name: folderName});
    string? folderId = folder.Id;
    if folderId is () {
        return error("Xero did not return an id for the created folder");
    }
    io:println("Created folder ", folderName, " with id ", folderId);

    files:FileObject uploaded = check xeroFiles->uploadFileToFolder(folderId, {xeroTenantId: tenantId}, {
        filename: documentName,
        name: documentName,
        mimeType: documentMimeType,
        body: documentBase64
    });
    string? fileId = uploaded.id;
    if fileId is () {
        return error("Xero did not return an id for the uploaded file");
    }
    io:println("Uploaded ", documentName, " with id ", fileId);

    files:Association association = check xeroFiles->createFileAssociation(fileId, {xeroTenantId: tenantId}, {
        objectId: invoiceId,
        objectGroup: "Invoice"
    });
    io:println("Linked file to invoice ", association.objectId);

    files:Association[] links = check xeroFiles->listFileAssociations(fileId, {xeroTenantId: tenantId});
    io:println("The file now has ", links.length(), " association(s)");
}
