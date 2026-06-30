#!/bin/bash
set -euo pipefail

# Copy the vendored MSAL dSYM into the archive only for Release archive builds.
if [[ "${CONFIGURATION:-}" != "Release" || "${ACTION:-}" != "install" ]]; then
  exit 0
fi

source_dsym="${SRCROOT}/Vendor/MSAL/MSAL.framework.dSYM"
destination_root="${DWARF_DSYM_FOLDER_PATH:-}"
destination_dsym="${destination_root}/MSAL.framework.dSYM"

if [[ ! -d "${source_dsym}" ]]; then
  echo "warning: MSAL dSYM not found at ${source_dsym}"
  exit 0
fi

mkdir -p "${destination_root}"
rm -rf "${destination_dsym}"
ditto "${source_dsym}" "${destination_dsym}"
echo "Copied MSAL dSYM to ${destination_dsym}"
