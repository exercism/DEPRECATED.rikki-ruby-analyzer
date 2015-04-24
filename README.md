# Analysseur

Analyseur provides an API wrapper for JacobNinja's exercism-analysis project (codeminer for exercism.io).

## Usage

Start the application on port 8989:

```
rackup -p 8989
```

Send a POST request to the `/analyze/:language` endpoint. E.g.

```
$ curl "http://localhost:8989/analyze/ruby" -H "Content-Type: application/json" -d '{
  "code": "class Thing\n    def stuff\n    end\nend"
}'
```

_Note: to get a string that is formatted nicely paste a heredoc into IRB. It will
escape things nicely._

## Testing locally

To lean on default configurations

1. Run exercism.io on port 4567
1. Run analysseur on port 8989
1. Run redis (just use the default port, 6379)
1. Run rikki with no arguments
1. Submit a problematic piece of code.
