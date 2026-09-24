# SportBar Unified 🏆

Sistema unificado de control audiovisual para sport bars — aplicación React que
gestiona una matriz HDMI-over-IP, canales deportivos, audio por zonas y presets,
orquestada por un **State Broker** en Express.

> Showcase público del proyecto SportBar. La documentación operativa interna
> (inventarios, topología de red y configuración de cada instalación) no forma
> parte de este repositorio.

## 📋 Qué hace

- **Control de matriz de video**: enrutamiento de fuentes (HDMI-over-IP) hacia
  decenas de destinos con selección por grupos y zonas
- **Estado compartido en red**: un broker Express mantiene el estado canónico
  (persistido en lowdb) y lo difunde vía SSE a múltiples clientes
- **Reconciliación con el hardware**: un reconciler server-side lee periódicamente
  el estado real de la matriz y lo reconcilia con el deseado (single-flight,
  tolerante a blips y con guard anti-carrera scan/write)
- **Canales y decodificadores**: cambio de canal por IR dinámico dígito a dígito,
  con intención server-side y ACK del controlador
- **Audio por zonas**: control vía serial (RS-232 enrutado por la matriz)
- **Sistema de presets**: 5 configuraciones completas guardables (servidor + cliente)

## 🏗️ Arquitectura

```
Cliente React (SPA)
   │  fetch (JSON, SSE)
   ▼
Express "State Broker"            ← única puerta de writes: writeQueue serializada,
   ├── broker/store.js                confirmación por settling, dedupe con escape `force`
   │     └─ state.json (lowdb, schema v3)
   ├── broker/arrangerClient.js    ← cliente HTTP del controlador AV (semáforo de
   │                                  concurrencia, timeout, mock para tests)
   ├── broker/reconciler.js        ← lecturas periódicas + auto-adopt con lectura
   │                                 confirmada (Arranger gana solo con evidencia)
   └── SSE /api/stream             ← broadcast de dominios versionados
```

- Un solo writer contra el hardware (`writeQueue`) y ventanas de settling por
  comando: el estado que reporta la UI siempre viene de lecturas confirmadas
- Los verifiers (`server/broker/verify/*.cjs`, `run-all.cjs`) validan cada dominio
  de forma aislada sobre mocks — sin hardware necesario

## 🛠️ Stack

| Capa | Tecnología |
|------|------------|
| Frontend | React 18.3.1 · Vite 5.4.21 · CSS Modules · Vitest |
| Backend | Express 4 · lowdb 7 · Helmet · SSE |
| Control AV | API HTTP del controlador (formato `join av`, `send ir`, `preset load`) |
| Tests | Vitest (frontend) + verifiers Node aislados por dominio |

## 🚀 Scripts

```bash
pnpm install                 # frontend
pnpm run serve               # broker Express (modo producción)
pnpm run dev:full            # dev server + broker
pnpm test                    # suite frontend
node server/broker/verify/run-all.cjs   # suite del broker
```

Configuración por variables de entorno (ver `.env.example`):
`VITE_ARRANGER_HOST`, `VITE_ARRANGER_TOKEN`, `ARRANGER_HOST`, `VITE_MOCK_ARRANGER`.

## 🧭 Estructura

```
src/          # App React (componentes, hooks, api, data)
server/       # State Broker: server.js + broker/ (store, writeQueue,
              #   reconciler, arrangerClient, arrangerErrors, arrangerPresets)
scripts/      # setup, bootstrap de worktrees, deploy (Docker)
public/       # assets
```

## 🤝 Soporte

`mailto:soporte@wetechar.com`