"""Idempotent post-align fixes for the Xero Files spec (keyed on path+method / schema).

Rewrites aligned_ballerina_openapi.json and re-dumps aligned_ballerina_openapi.yaml from it.
"""
import json, os
import yaml

here = os.path.dirname(__file__)
f = os.path.join(here, 'aligned_ballerina_openapi.json')
d = json.load(open(f))
schemas = d['components']['schemas']

# 1. ObjectIds is a comma-separated list, not repeated ObjectIds= parameters
for p in d['paths']['/Associations/Count']['get']['parameters']:
    if p.get('name') == 'ObjectIds':
        p['explode'] = False

# 2. The upload body is the file itself, sent as a file part, not a base64 string
schemas['FileUploadRequest']['properties']['body'] = {'type': 'string', 'format': 'binary'}

# 3. FileObject's `required` names properties it does not have (id, manufacturer, name,
#    releaseDate); updateFile also sends a partial FileObject, so nothing is required
schemas['FileObject'].pop('required', None)

# 4. Folder: declare it an object, camelCase field names like the other records, and point
#    `required` at the real Name property
folder = schemas['Folder']
folder['type'] = 'object'
folder['required'] = ['Name']
for name, prop in folder['properties'].items():
    prop['x-ballerina-name'] = name[0].lower() + name[1:]
schemas['Folder'] = {'required': folder.pop('required'), 'type': folder.pop('type'), **folder}

with open(f, 'w') as out:
    json.dump(d, out, indent=4, ensure_ascii=False)
with open(os.path.join(here, 'aligned_ballerina_openapi.yaml'), 'w') as out:
    yaml.safe_dump(d, out, sort_keys=False, width=100)
