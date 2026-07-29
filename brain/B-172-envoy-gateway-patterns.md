---
id: B-172
tags: [envoy, gateway, gotcha, code]
scope: any Envoy static-config gateway
hook: Envoy gateway cookbook — offline validate, multi-listener shared HCM via YAML anchor, TLS listener, local_ratelimit, and the CORS double-header trap
---

# Envoy gateway patterns (static config)

**Validate offline** (no cluster needed) with the real binary before deploying:
```
docker run --rm -v "$PWD/envoy.yaml:/etc/envoy/envoy.yaml:ro" \
  -v "$PWD/certs:/etc/envoy/certs:ro" \
  envoyproxy/envoy:v1.31-latest --mode validate -c /etc/envoy/envoy.yaml
```
Prints "configuration '...' OK". Catches type-URL/shape errors instantly.

**One HCM, two listeners (HTTP + HTTPS) via YAML anchor** — define routing/filters once: put
`typed_config: &hcm { ...HttpConnectionManager... }` on the http listener and `typed_config: *hcm` on
the https listener. YAML anchors expand before proto parsing, so both share identical routing.

**TLS listener**: filter_chain `transport_socket` = `DownstreamTlsContext` with
`common_tls_context.tls_certificates[].certificate_chain/private_key` → `{ filename: ... }`.
Self-signed dev cert: `openssl req -x509 -newkey rsa:2048 -nodes -keyout k -out c -days 825
-subj /CN=localhost -addext subjectAltName=DNS:localhost,IP:127.0.0.1`. Gitignore the certs; ship a gen script.

**local_ratelimit** (coarse DoS backstop, no external RLS): add `envoy.filters.http.local_ratelimit`
BEFORE the router with a `token_bucket` (max_tokens/tokens_per_fill/fill_interval) +
`filter_enabled`/`filter_enforced` `{numerator:100,denominator:HUNDRED}`. Over-limit → 429. **Gotchas:**
`response_headers_to_add` only decorate 429 responses (NOT OK) — absence on 200s is not proof it's off;
check `curl <admin>/stats | grep local_rate_limit` or test with a tiny bucket (max_tokens:5) to see
429s deterministically (per-request curl can't reliably exceed a 1000/s bucket).

**CORS double-header trap**: adding an Envoy CORS filter in FRONT of upstreams that already emit CORS
yields `Access-Control-Allow-Origin: *,*` (browser-rejected). Either own CORS solely at the gateway
(strip it from upstreams) OR pass upstream CORS through (no gateway CORS filter). Don't do both. See [[B-174]].

Related: [[B-173]] docker reload.
