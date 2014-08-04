# Analysseur

Analyseur provides an API wrapper for JacobNinja's exercism-analysis project (codeminer for exercism.io).

## Usage

Send a POST request to the `/analyze/:language` endpoint. E.g.

```
$ curl "http://localhost:8989/analyze/ruby" -H "Content-Type: application/json" -d '{
  "code": "class Thing\n    def stuff\n    end\nend"
}'
```
