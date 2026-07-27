---
id: B-174
tags: [nginx, cors, gateway, cache, gotcha]
scope: any nginx reverse-proxy / HLS edge
hook: Two nginx CORS pitfalls + the auth_request pattern for caching token-gated immutable assets across users
---

# nginx edge: CORS duplication + token-gated shared caching

**1. Duplicate `Access-Control-Allow-Origin` → browser-rejected `*,*`.**
If nginx `proxy_pass`es an upstream that ALSO sets CORS (e.g. a Gin/Express app), and the nginx
location adds its own `add_header Access-Control-Allow-Origin "*"`, the response carries TWO ACAO
headers. A downstream (e.g. Envoy) may fold them into `*,*`, which browsers reject. Fix: drop the
upstream's copy in the proxy location — `proxy_hide_header Access-Control-Allow-Origin;` — so exactly
one remains. (nginx `add_header` does NOT dedupe against proxied headers.) Corollary:
`Access-Control-Allow-Origin: *` + `Access-Control-Allow-Credentials: true` is invalid per spec —
browsers drop credentialed responses. Pick one.

**2. Cache token-gated immutable assets across viewers via `auth_request`.**
Naive gating puts the token in the cache key (`proxy_cache_key ...$args$http_authorization`), so every
viewer's unique JWT makes a separate cache entry for the SAME immutable segment → ~0% hit ratio,
origin hit per viewer. Instead: validate per-request but key the cache on `$uri` only.

```nginx
location = /_auth {            # internal auth_request target
    internal;
    proxy_pass http://origin/api/playback/verify;   # returns 204 allow / 401 / 403
    proxy_pass_request_body off;
    proxy_set_header Content-Length "";
    proxy_set_header X-Original-URI $request_uri;    # token is in the query here
    proxy_set_header Authorization $http_authorization;
}
location ~* \.(m4s|ts|mp4)$ {
    auth_request /_auth;                 # per-request enforcement (runs on cache hits too)
    proxy_cache_key $scheme$proxy_host$uri;   # NO token → shared body cache
    proxy_pass http://origin;
    proxy_cache_valid 200 24h;
}
```
The verify endpoint returns 204 when the gate is disabled (open by default). OPTIONS preflight
short-circuits (`if ($request_method=OPTIONS){return 204;}`) before auth_request, so preflight isn't
blocked. Verified live: no-token 401, valid-token 200 then `X-Cache-Status: HIT`, bad-token 401.

Related: [[B-173]], [[B-172]].
