# n8n-joplin

*WIP*

Working towards [https://n8n.io](n8n.io) integration with [Joplin](https://joplinapp.org/)


### Usage:
`docker-compose up --build`

#### Optional:
Add a Joplin configuration JSON file o(i.e. with the contents of a `joplin config --export` from another Joplin instance) to `./joplin-config.json` and it will be loaded via `joplin --import-file` in the docker container.

Sample `joplin-config.json` for S3-based sync:
```
{
  "sync.target": 8,
  "sync.8.url": "https://s3.us-east-1.wasabisys.com",
  "sync.8.path": "bucket",
  "sync.8.username": "S3ACCESSKEY",
  "sync.8.password": "S3SECRET",
  "sync.interval": 300,
  "sync.maxConcurrentConnections": 5,
  "sync.resourceDownloadMode": "manual",
  "sync.wipeOutFailSafe": true,
  "api.port": 41187,
  "api.token": "abc123"
}
```
