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

`secrets/app.sops.env` is the single source of truth for this stack, so a value
two services share is stored once:

- `S3_*` — the Joplin sync target's credentials.
- `JOPLIN_API_TOKEN` — the clipper API token.
- `POP3_*`, `GETMAIL_OPTS`, `DEFAULT_TITLE_PREFIX`, `*_NOTEBOOK` — mail-to-notes
  values; no service in `docker-compose.yml` consumes them yet.

`.envrc` decrypts that file, then builds the Joplin config from it:
`joplin-config.base.json` holds the non-secret settings, the secrets are merged in
with `jq`, and the result is exported as `JOPLIN_CONFIG_JSON_B64`. The container
decodes it into tmpfs, so no config file exists on this machine or on the Docker
daemon's host.

That also means the credentials are already in the shell environment for anything
else in the stack that needs them — pass `S3_KEY`/`S3_SECRET` through in
`docker-compose.yml` rather than adding a second encrypted copy.

The file is encrypted to `&user_jeff` plus both recovery masters (see
`.sops.yaml`), so the user age key is enough for day-to-day edits:

```bash
sops secrets/app.sops.env
```

Decryption uses `~/.config/sops/age/keys.txt`, installed on macOS by nix-darwin
from the `nix-secrets` flake input.

`JOPLIN_API_TOKEN` is still the sample value from the upstream documentation;
change it here and in the workflow URL together.

## Configuration

Joplin's config is the JSON that `joplin config --export` produces, split in two:

- `joplin-config.base.json` (committed) — settings that are not secret, such as
  `sync.target`, `sync.interval` and the concurrency/fallback flags.
- the encrypted values in `secrets/app.sops.env` — `sync.8.url/path/username/password`
  and `api.token`, mapped to their Joplin names by `.envrc`.

Edit the base file for behavioural changes and `sops secrets/app.sops.env` for
credentials. There is no plaintext config in the working tree.
