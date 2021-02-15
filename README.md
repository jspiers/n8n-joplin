# n8n-joplin

*WIP*

Working towards [n8n.io](https://n8n.io) integration with [Joplin](https://joplinapp.org/)


## Usage:
`docker-compose up`
and access n8n by opening a web browser to http://localhost:5678

The Joplin web clipper is accessible from within n8n (e.g. for the [HTTP Request node](https://docs.n8n.io/nodes/n8n-nodes-base.httpRequest/)) via address http://joplin/notes?token=mysupersecrettoken123

## Example n8n workflow
From the n8n interface, import `joplin_notes_workflow.json`

## Configuration:
Add a Joplin configuration JSON file o(i.e. with the contents of a `joplin config --export` from another Joplin instance) to `./joplin-config.json` and it will be loaded via `joplin --import-file` in the docker container.

Sample `joplin-config.json` for S3-based sync:
```
{
  "sync.target": 8,
  "sync.8.url": "https://s3.us-east-1.wasabisys.com",
  "sync.8.path": "bucket",
  "sync.8.username": "S3ACCESSKEY",
  "sync.8.password": "S3SECRET",
  "sync.maxConcurrentConnections": 5,
  "sync.resourceDownloadMode": "manual",
  "sync.wipeOutFailSafe": true,
  "api.token": "mysupersecrettoken123"
}
```
