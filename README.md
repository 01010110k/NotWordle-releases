# Word 99 — build artifacts + Xcode Cloud CI

Release assets for Word 99 (source repo is private). This repo is also the live
Xcode Cloud pipeline: `ci_scripts/ci_post_clone.sh` downloads the Unity-generated
Xcode export pinned in `build.env`, unpacks it at the repo root, stamps the build
number and compliance flag, then Xcode Cloud archives it and uploads to TestFlight.

## Release flow

1. The source repo's `tools/publish-ios.sh` exports the project from Unity, uploads
   `Word99-Xcode.zip` as a release asset here under a new dated tag, and sets
   `RELEASE_TAG=<tag>` in `build.env`.
2. The `build.env` push to `main` (the workflow's file filter) triggers Xcode Cloud.
3. Xcode Cloud archives `Unity-iPhone` (cloud-managed signing) → TestFlight.

## Invariants

- The `Unity-iPhone` scheme must stay shared; no certs/profiles in the export.
- `CFBundleVersion` is stamped from `CI_BUILD_NUMBER` at build time.
- The export contains files above GitHub's 100 MB cap — it is downloaded at build
  time and must never be committed (enforced by `.gitignore`'s allowlist).

Full operational runbook (identifiers, workflow config, gotchas) lives in the
private source repo: `docs/ios-cicd.md`.
