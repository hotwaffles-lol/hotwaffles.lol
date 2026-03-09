# hotwaffles.lol — Root Project

## What this is
Static personal site hosted on AWS S3. The repo root is also the deployment root — the folder structure here mirrors the S3 bucket structure and therefore the live URL paths.

## Folder structure
```
/                   → hotwaffles.lol/          (static, index.html + waffle.png)
/fitmapped/         → hotwaffles.lol/fitmapped/ (static HTML + images, no build step)
/photostitch/       → hotwaffles.lol/photostitch/ (Vite/React app, built via npm)
/woodshops/         → hotwaffles.lol/woodshops/  (Vite/React app, built via npm)
```

## Deployment
Run `deploy.sh` from the repo root:
```bash
S3_BUCKET=your-bucket-name ./deploy.sh
```

The script:
1. Cleans and rebuilds `out/` (gitignored staging dir)
2. Copies root `index.html` + `waffle.png` → `out/`
3. Rsyncs `fitmapped/` → `out/fitmapped/` (excludes `.Codex`, `.DS_Store`)
4. Builds `photostitch/` → copies `dist/` → `out/photostitch/`
5. Builds `woodshops/` → copies `dist/` → `out/woodshops/`
6. Runs `aws s3 sync out/ s3://BUCKET/ --delete`

## Critical rules
- **Never delete or modify `deploy.sh`** without understanding the full deployment flow.
- **Never commit the `out/` directory** — it is gitignored and is a build artifact.
- **Never change the `base` in a Vite config** without understanding the URL path it serves under. `photostitch` must use `base: '/photostitch/'` and `woodshops` must use `base: '/woodshops/'` or asset paths will break in production.
- **`fitmapped/` has no build step** — edit files there directly. Images and other assets placed in `fitmapped/` will be synced to S3 automatically.
- Both Vite apps use **npm** (not bun, not yarn). Use `npm install` and `npm run build`.

## Sub-project AGENTS.md files
Each subfolder has its own AGENTS.md with project-specific context. Read it before making changes inside that folder.
