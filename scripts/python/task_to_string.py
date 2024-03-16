from sys import argv
import json

execution_id=argv[1]
project=argv[2]
caller_class=argv[3]
callee_class=argv[4]

data = {
        'execution_id': execution_id,
        'project': project,
        'caller_class': caller_class,
        'callee_class': callee_class
        }


read_json =  json.dumps(data)
print read_json.replace(",", "|")
