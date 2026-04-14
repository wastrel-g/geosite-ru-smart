# geosite-ru-smart

Curated geosite.dat for Russian users — built on top of v2fly/domain-list-community with RF-specific additions.

**Design goals:**
- **RF anti-fraud scanners MUST go DIRECT** — banks, marketplaces, attribution trackers (AppsFlyer/Firebase/reCAPTCHA)
- **IP-check services DIRECT** — 150+ endpoints from v2fly + custom, so VPN isn't detected
- **RKN-blocked services PROXY** — Meta/X/LinkedIn/Discord/TikTok/Spotify/Western media/AI
- **Torrent trackers BLOCK** — save relay bandwidth + hoster TOS
- **No tracker blocking** — RF apps break when Firebase/AppsFlyer can't reach their SDK endpoints

## Categories

### Direct (RU traffic)
| Category | Purpose |
|---|---|
| `ru-banks` | Сбер / Т-Банк / ВТБ / Альфа / все из снимка ЦБ |
| `ru-scanners` | AppsFlyer / Adjust / Firebase / reCAPTCHA / Group-IB |
| `ru-ipcheck` | 2ip / ipinfo / whoer / browserleaks + v2fly category-ip-geo-detect |
| `ru-gov` | Госуслуги / nalog / cbr / regional |
| `ru-ecosystem` | Яндекс / VK / Mail.ru / MTС / 2GIS |
| `ru-marketplaces` | Ozon / WB / Avito / Megamarket |
| `ru-games` | Steam / Epic / Tarkov / Warface / Faceit |
| `ru-apple-push` | Apple courier.push CIDRs (fix iOS пуши) |
| `direct-ru` | **Composite: include all of the above** |

### Proxy (RKN-blocked)
| Category | Purpose |
|---|---|
| `rkn-social` | Meta / X / LinkedIn / Discord / Signal / TikTok / Reddit |
| `rkn-media` | BBC / DW / NYT / RFE/RL / Meduza / TV Rain |
| `rkn-ai` | OpenAI / Claude / Gemini / Perplexity / Copilot |
| `rkn-audio` | Spotify / Tidal / Deezer / SoundCloud |
| `rkn-vpn-info` | Tor / Proton / VPN knowledge |
| `rkn-adult` | Adult (opt-in) |
| `proxy-rkn` | **Composite: include all + youtube/telegram/google-play/github** |

### Block
| Category | Purpose |
|---|---|
| `block-ads` | Ad networks + Windows telemetry (NOT trackers used by RF apps) |
| `block-torrent` | Public torrent trackers + DHT |
| `block-all` | **Composite: ads + torrent** |

## Usage in Happ routing

```json
{
  "Name": "RU-smart",
  "GlobalProxy": "true",
  "RouteOrder": "block-proxy-direct",
  "Geositeurl": "https://github.com/wastrel-g/geosite-ru-smart/releases/latest/download/geosite.dat",
  "Geoipurl": "https://github.com/hydraponique/roscomvpn-geoip/releases/latest/download/geoip.dat",
  "DirectSites": ["geosite:direct-ru"],
  "DirectIp":    ["geoip:private", "geoip:direct"],
  "ProxySites":  ["geosite:proxy-rkn"],
  "ProxyIp":     [],
  "BlockSites":  ["geosite:block-all"],
  "BlockIp":     [],
  "DomainStrategy": "IPIfNonMatch"
}
```

## Build locally

```bash
./build.sh
# → release/geosite.dat
```

## Build via GitHub Actions

Pushes to `main` trigger a build. A daily cron also rebuilds to pick up v2fly/domain-list-community upstream updates.

Release URL pattern:
- Latest: `https://github.com/wastrel-g/geosite-ru-smart/releases/latest/download/geosite.dat`
- Pinned: `https://github.com/wastrel-g/geosite-ru-smart/releases/download/YYYYMMDDHHMM/geosite.dat`

## Contributing

Add or update data files in `data/`. Format is v2fly standard:
```
domain:example.com          # matches example.com AND all subdomains
full:www.example.com        # matches exactly this FQDN
regexp:^.+\.example\.com$   # regex
keyword:example             # substring match
include:other-category      # include another file
```

## Maintainer checklist

Weekly:
- [ ] Check RKN reestr for newly blocked services → add to `rkn-*`
- [ ] Audit `ru-banks` against CBR registry changes
- [ ] Test critical flows: Sber login, Tinkoff payment, Госуслуги, 2ip.io showing RF IP

Monthly:
- [ ] Check v2fly/domain-list-community for new relevant categories
- [ ] Run `deduplicate.py` to drop domains covered by geoip direct

## License

MIT
