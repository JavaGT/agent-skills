---
name: porkbun-dns
description: Manage DNS records on Porkbun. Use when user asks to create, update, delete, or list DNS records. Reads credentials from ~/.secrets/porkbun.env (PORKBUN_API_KEY, PORKBUN_SECRET_KEY); env vars take precedence.
---

# Porkbun DNS Management

This skill uses the Porkbun API to manage DNS records. API credentials are
loaded from `~/.secrets/porkbun.env` (dotenv format). The env vars
`PORKBUN_API_KEY` and `PORKBUN_SECRET_KEY` may also be set directly by the
harness; those take precedence.

⚠️ Porkbun field name gotcha: the secret is sent as **`secretapikey`** in the
JSON body — NOT `secret` or `secretkey`. The key is `apikey`.

## Available Commands

### List all DNS records for a domain
```
!`set -a && source ~/.secrets/porkbun.env && curl -s "https://api.porkbun.com/api/json/v3/dns/retrieve/$ARGUMENTS" -H "Content-Type: application/json" -d "{\"apikey\":\"$PORKBUN_API_KEY\",\"secretapikey\":\"$PORKBUN_SECRET_KEY\"}"`
```

### Create a DNS record
```
!`set -a && source ~/.secrets/porkbun.env && curl -s "https://api.porkbun.com/api/json/v3/dns/create/$ARGUMENTS" -H "Content-Type: application/json" -d "{\"apikey\":\"$PORKBUN_API_KEY\",\"secretapikey\":\"$PORKBUN_SECRET_KEY\"}"`
```

### Delete a DNS record
```
!`set -a && source ~/.secrets/porkbun.env && curl -s "https://api.porkbun.com/api/json/v3/dns/delete/$ARGUMENTS" -H "Content-Type: application/json" -d "{\"apikey\":\"$PORKBUN_API_KEY\",\"secretapikey\":\"$PORKBUN_SECRET_KEY\"}"`
```

### Check API credentials
```
!`set -a && source ~/.secrets/porkbun.env && curl -s "https://api.porkbun.com/api/json/v3/ping" -H "Content-Type: application/json" -d "{\"apikey\":\"$PORKBUN_API_KEY\",\"secretapikey\":\"$PORKBUN_SECRET_KEY\"}"`
```

## Usage Examples

**List records for javagrant.ac.nz:**
```
/porkbun-dns list javagrant.ac.nz
```

**Create CNAME record for tools subdomain:**
```
/porkbun-dns create javagrant.ac.nz name:tools type:CNAME content:javagrant.github.io ttl:600
```

**Delete a record:**
```
/porkbun-dns delete javagrant.ac.nz record_id:542273339
```

**Verify credentials:**
```
/porkbun-dns ping
```

## Record Format for Create/Edit

When creating records, include these fields in JSON:
- `name` - subdomain (e.g., "tools" for tools.javagrant.ac.nz)
- `type` - A, AAAA, CNAME, MX, TXT, etc.
- `content` - the record value (IP, hostname, etc.)
- `ttl` - time to live in seconds (default: 600)
- `prio` - priority for MX records

## Domain Format

Always specify the full domain (e.g., `javagrant.ac.nz`, not just `javagrant`).

## Credential Setup

Create `~/.secrets/porkbun.env` (chmod 600):
```
PORKBUN_API_KEY=pk1_...
PORKBUN_SECRET_KEY=sk1_...
```
Generate keys at https://porkbun.com/account/api. Validate with the `ping`
command above — expect `"status":"SUCCESS"` and `"credentialsValid":true`.
