#!/bin/sh
set -eu
WS="${TRACE_PROJECT_ROOT:-/workspaces/project}"
export HOME="${TRACE_HOME:-$WS/.cache/trace-home}"
mkdir -p "$HOME/.trace"

# Runtime config only (not upstream source). Preset keeps server-side surface small;
# docker/mcp-gateway tools.yaml remains the hard allowlist.
cat >"$HOME/.trace/.config.json" <<'EOF'
{
  "tools": {
    "preset": "minimal",
    "description_verbosity": "minimal",
    "instructions_verbosity": "minimal"
  },
  "telemetry": { "usage_ping": false }
}
EOF

if [ -d "$WS" ]; then
  # Register + index; ignore non-zero on re-register races.
  trace add "$WS" || true
fi

exec trace serve-http --host 0.0.0.0 --port 3741 --allow-remote
