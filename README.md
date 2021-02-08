# n8n-joplin

*WIP*

Working towards [https://n8n.io](n8n.io) integration with [Joplin](https://joplinapp.org/)


### Usage:
`docker-compose up --build`

#### Optional:
Add a Joplin configuration JSON file o(i.e. with the contents of a `joplin config --export` from another Joplin instance) to `./joplin-config.json` and it will be loaded via `joplin --import-file` in the docker container.
