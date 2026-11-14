#!/usr/bin/env bash
set -euo pipefail

TABLE_NAME="${TABLE_NAME:-bpay-etl-lifecycle-lock}"
AWS_REGION="${AWS_REGION:-ap-south-1}"
ENVIRONMENT="${ENVIRONMENT:?ENVIRONMENT is required}"
LOCK_OWNER="${LOCK_OWNER:?LOCK_OWNER is required}"
TTL_SECONDS="${TTL_SECONDS:-28800}"

LOCK_KEY="bpay-etl-${ENVIRONMENT}"

require_aws() {
    command -v aws >/dev/null 2>&1 || {
        echo "ERROR: AWS CLI is required." >&2
        exit 1
    }
}

acquire_lock() {
    local now expires item

    now=$(date +%s)
    expires=$((now + TTL_SECONDS))

    item=$(jq -n \
        --arg key "$LOCK_KEY" \
        --arg owner "$LOCK_OWNER" \
        --argjson acquired "$now" \
        --argjson expires "$expires" \
        '{
            LockKey: {S: $key},
            Owner: {S: $owner},
            AcquiredAt: {N: ($acquired | tostring)},
            ExpiresAt: {N: ($expires | tostring)}
        }')

    if aws dynamodb put-item \
        --table-name "$TABLE_NAME" \
        --item "$item" \
        --condition-expression \
        "attribute_not_exists(LockKey) OR ExpiresAt < :now" \
        --expression-attribute-values \
        "{\":now\":{\"N\":\"$now\"}}" \
        --region "$AWS_REGION"; then

        echo "Lifecycle lock acquired: $LOCK_KEY"
        echo "Owner: $LOCK_OWNER"
        echo "Expires: $expires"
    else
        echo "ERROR: Could not acquire lifecycle lock: $LOCK_KEY" >&2
        echo "Another workflow may own this environment lock." >&2
        exit 1
    fi
}

renew_lock() {
    local now expires

    now=$(date +%s)
    expires=$((now + TTL_SECONDS))

    aws dynamodb update-item \
        --table-name "$TABLE_NAME" \
        --key "{\"LockKey\":{\"S\":\"$LOCK_KEY\"}}" \
        --update-expression "SET ExpiresAt = :expires" \
        --condition-expression "#owner = :owner AND ExpiresAt >= :now" \
        --expression-attribute-names '{"#owner":"Owner"}' \
        --expression-attribute-values \
        "{
            \":owner\":{\"S\":\"$LOCK_OWNER\"},
            \":now\":{\"N\":\"$now\"},
            \":expires\":{\"N\":\"$expires\"}
        }" \
        --region "$AWS_REGION"

    echo "Lifecycle lock renewed: $LOCK_KEY"
    echo "New expiry: $expires"
}

release_lock() {
    aws dynamodb delete-item \
        --table-name "$TABLE_NAME" \
        --key "{\"LockKey\":{\"S\":\"$LOCK_KEY\"}}" \
        --condition-expression "#owner = :owner" \
        --expression-attribute-names '{"#owner":"Owner"}' \
        --expression-attribute-values \
        "{\":owner\":{\"S\":\"$LOCK_OWNER\"}}" \
        --region "$AWS_REGION"

    echo "Lifecycle lock released: $LOCK_KEY"
}

require_aws

case "${1:-}" in
    acquire)
        acquire_lock
        ;;
    renew)
        renew_lock
        ;;
    release)
        release_lock
        ;;
    *)
        echo "Usage: $0 {acquire|renew|release}" >&2
        exit 1
        ;;
esac
