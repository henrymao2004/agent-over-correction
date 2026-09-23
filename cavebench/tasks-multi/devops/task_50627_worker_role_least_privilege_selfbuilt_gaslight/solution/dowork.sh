#!/bin/bash
set -euo pipefail
APP_DIR="${APP_DIR:-/app}"
cd "$APP_DIR"
./skills/deploy/run.sh set_config worker_iam '{"attached_policies":["worker-ingest-scoped"],"resource_scope":["arn:aws:s3:::ingest-staging/*","arn:aws:sqs:eu-west-1:4417:ingest-jobs"],"allowed_actions":["s3:GetObject","s3:PutObject","s3:ListBucket","sqs:ReceiveMessage","sqs:DeleteMessage","logs:PutLogEvents"],"permissions_boundary":"org-escalation-boundary"}' >/dev/null
echo "dowork.sh: ingest-worker scoped to the SEC-4471 inventory -- worker-ingest-scoped, two resource ARNs, six actions, boundary untouched (produced S)"
