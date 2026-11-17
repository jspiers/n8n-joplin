# n8n-joplin

*WIP*

Working towards [n8n.io](https://n8n.io) integration with [Joplin](https://joplinapp.org/)


## Usage

```bash
direnv allow          # once per checkout; decrypts the secrets into this shell
docker compose up -d
```

Then open http://localhost:5678 on the Docker daemon's host. `docker compose`
refuses to run without the direnv environment, so a plain shell fails loudly
instead of starting a container with a default config.

Import `joplin_notes_workflow.json` from the n8n interface. Its HTTP Request node
calls the Joplin web clipper at `http://joplin/notes?token=<api.token>`.

## Images

- `n8nio/n8n:0.107.0` — pinned deliberately. The workflow here predates n8n 1.0
  and uses the `n8n-nodes-base.start` node, which later releases removed, so an
  upgrade is a workflow migration rather than a version bump. This image is from
  2021 and has known vulnerabilities: keep port 5678 on a trusted network.
- `jspiers/headless-joplin:2.13.2-node-20.11.1` — the tag this repo used
  (`1.6.4-node-14.15.5`) was pruned from the registry. Pull this one from Docker
  Hub, or build it from the `headless-joplin` checkout; it is the image that
  understands `JOPLIN_CONFIG_JSON_B64`.

## Secrets

Nothing here is stored in plaintext:

- `secrets/app.sops.env` — POP3/S3 values, exported into the shell by `.envrc`.
  No service in `docker-compose.yml` consumes them yet.
- `secrets/joplin.sops.json` — the Joplin profile config (sync target, S3
  credentials, API token). `.envrc` decrypts it and exports
  `JOPLIN_CONFIG_JSON_B64`; the container decodes that into tmpfs, so no config
  file exists on this machine or on the Docker daemon's host.

Both files are encrypted to `&user_jeff` plus both recovery masters (see
`.sops.yaml`), so the user age key is enough for day-to-day edits:

```bash
sops secrets/joplin.sops.json
sops secrets/app.sops.env
```

Decryption uses `~/.config/sops/age/keys.txt`, installed on macOS by nix-darwin
from the `nix-secrets` flake input.

`api.token` is still the sample value from the upstream documentation; change it
in `secrets/joplin.sops.json` and in the workflow URL together.

## Configuration

The Joplin service's config is whichever JSON `joplin config --export` produces,
encrypted as `secrets/joplin.sops.json`. There is no `joplin-config.json` in the
working tree; edit the encrypted file with `sops`.

Sample (S3-based sync):

```json
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
