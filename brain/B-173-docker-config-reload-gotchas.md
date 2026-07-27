---
id: B-173
tags: [docker, gotcha]
scope: any docker-compose stack
hook: Config changes don't apply until the RIGHT reload — bind-mount needs --force-recreate, image-baked needs rebuild, proxy caches replay stale headers, and 127.0.0.1 admin isn't host-reachable
---

# Docker/compose config-reload gotchas

Hit repeatedly making config edits "not take effect" on nginx/Envoy. The edit was on disk; the running
container was serving stale config. Rules:

1. **Bind-mounted config → `docker compose up -d` does NOT reload it.** Compose only recreates a
   container when the *compose service definition* changes, not when a bind-mounted file's contents
   change. And most servers (nginx, Envoy) don't hot-reload a mounted file. Force it:
   `docker compose up -d --force-recreate <svc>`.

2. **Image-baked config → recreate is NOT enough; rebuild the image.** If the Dockerfile `COPY`s the
   config into the image, editing the source file changes nothing until `docker compose build <svc>` +
   recreate. Symptom: `grep` the file *inside* the container
   (`docker compose exec svc grep X /etc/.../conf`) shows the OLD content. Diagnostic that saves time:
   always grep the in-container file, not the host file.

3. **proxy_cache replays stale response headers.** After fixing a header bug at the origin/edge, cached
   entries still serve the OLD headers until the cache clears. `--force-recreate` on an image-local
   cache dir clears it; a named cache volume does not.

4. **Admin/diagnostic port bound to 127.0.0.1 is unreachable via host port map.** Envoy admin
   `address: 127.0.0.1:9901` + compose `ports: 9901:9901` → host `localhost:9901` still fails (host
   maps to the container's 0.0.0.0, not its loopback). Reach it with
   `docker compose exec <svc> curl http://127.0.0.1:9901/...`.

Related: [[B-174]] (nginx edge), [[B-172]] (Envoy).
