_Author_:  @DimuthuMadushan \
_Created_: 2026/09/30 \
_Updated_: 2026/09/30 \
_Edition_: Swan Lake

# Sanitation for OpenAPI specification

This document records the sanitation done on top of the official OpenAPI specification from Xero Files. 
The OpenAPI specification is obtained from [wso2/api-specs](https://github.com/wso2/api-specs/blob/main/openapi/xero/files/19.0.0/openapi.yaml).
These changes are done in order to improve the overall usability, and as workarounds for some known language limitations.

1. Rename operations to the list/count naming convention.

   Original: `getFiles`, `getFolders`, `getFileAssociations`, `getAssociationsByObject`, `getAssociationsCount` \
   Updated: `listFiles`, `listFolders`, `listFileAssociations`, `listObjectAssociations`, `countAssociations`

   **Reason**: These operations return collections or counts, so the names follow the `list*`/`count*` convention and are not confused with the single-item `get*` operations.

2. Rename schemas.

   Original: `Files`, `UploadObject` \
   Updated: `FileList`, `FileUploadRequest`

   **Reason**: `Files` is a page of files, and `UploadObject` is the multipart request body of the two upload operations.

3. Fill in the missing request body descriptions and replace generic success response descriptions.

   Original: empty request body descriptions, and `search results matching criteria` / `A successful request` on the 200 and 201 responses \
   Updated: a description that names the payload or the returned resource, for example `List of files` and `File uploaded to the folder`

   **Reason**: The generic wording carried no information about the operation and ended up in the generated documentation.

4. Path parameter names are normalised by `bal openapi align`.

   Original: `{FileId}`, `{FolderId}`, `{ObjectId}` \
   Updated: `{fileId}`, `{folderId}`, `{objectId}`

   **Reason**: Path parameters become Ballerina identifiers and must be camelCase.

5. Known limitation: `POST /Files/{folderId}` and `PUT /Files/{fileId}` share a path template that differs only by parameter name.

   **Reason**: This is how Xero documents them. Both are kept, and the client methods are remote, so there is no resource-path conflict.
6. Send the upload body as a file.

   Original: `FileUploadRequest.body` is `type: string, format: byte` \
   Updated: `type: string, format: binary`

   **Reason**: The upload operations carry the file itself in a multipart part. As a byte string the body was typed `string` and sent as a text part, so Xero stored the base64 text instead of the document. As binary it is typed `record {byte[] fileContent; string fileName;}`, which `createBodyParts` sends as a file part with a filename. This takes effect only once `uploadFile` and `uploadFileToFolder` pass the payload to `createBodyParts` directly. The generated `createBodyParts(check jsondata:toJson(payload).ensureType())` turns the bytes into a JSON array first. Applied to the original spec (`UploadObject`, which align renames to `FileUploadRequest`).

7. Send `ObjectIds` as a comma-separated list.

   Original: the `ObjectIds` query parameter of `GET /Associations/Count` has `explode: true` \
   Updated: `explode: false`

   **Reason**: The parameter is documented as a comma-separated list of object IDs. With `explode: true` several IDs were sent as repeated `ObjectIds=` parameters.

8. Remove the `required` list from `FileObject`.

   Original: `required: [id, manufacturer, name, releaseDate]` \
   Updated: no `required` list

   **Reason**: None of these names match a `FileObject` property (the properties are PascalCase, and `manufacturer` and `releaseDate` do not exist). `updateFile` sends a partial `FileObject`, for example only `FolderId`, so no property is made required in its place.

9. Align the `Folder` schema with the other record schemas.

   Original: no `type`, `required: [name]`, no `x-ballerina-name` on the properties \
   Updated: `type: object`, `required: [Name]`, and `x-ballerina-name` giving camelCase field names (`name`, `fileCount`, `email`, `isInbox`, `id`)

   **Reason**: Without the mapping the generated `Folder` fields were PascalCase, unlike every other record in the connector. `required` named a property that does not exist.

Items 6 to 9 are applied directly to the original `docs/spec/openapi.yaml`, so flatten and align carry them into the aligned spec without any further step.

## OpenAPI cli command

The following command was used to generate the Ballerina client from the OpenAPI specification. The command should be executed from the repository root directory.

```bash
bal openapi -i docs/spec/aligned_ballerina_openapi.json -o ballerina --mode client --license docs/license.txt --client-methods remote
```
Note: The license year is hardcoded to 2024, change if necessary.
