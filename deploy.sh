#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="$(dirname "$0")/.env"
if [ -f "$ENV_FILE" ]; then
  set -a
  . "$ENV_FILE"
  set +a
fi

BUCKET="${S3_BUCKET:-hotwaffles.lol}"
AWS_PROFILE="${AWS_PROFILE:-hotwaffles.lol-deployer}"
CF_DISTRIBUTION_ID="${CF_DISTRIBUTION_ID:-E18M1HAH9AZBZ8}"
OUT="$(dirname "$0")/out"

echo "==> Cleaning out/"
rm -rf "$OUT"
mkdir -p "$OUT"

echo "==> Copying root"
cp index.html waffle.png "$OUT/"

echo "==> Copying fitmapped/"
rsync -a --exclude='.claude' --exclude='.DS_Store' fitmapped/ "$OUT/fitmapped/"

echo "==> Building photostitch"
(cd photostitch && npm run build)
cp -r photostitch/dist/ "$OUT/photostitch/"

echo "==> Building woodshops"
(cd woodshops && npm run build)
cp -r woodshops/dist/ "$OUT/woodshops/"

echo "==> Syncing to s3://$BUCKET/"
aws s3 sync "$OUT/" "s3://$BUCKET/" --delete --profile "$AWS_PROFILE"

echo "==> Invalidating CloudFront cache"
aws cloudfront create-invalidation \
  --distribution-id "$CF_DISTRIBUTION_ID" \
  --paths "/*" \
  --profile "$AWS_PROFILE"

echo "==> Done"
