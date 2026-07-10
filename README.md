# Word 99 — build artifacts + Xcode Cloud CI

Release assets for Word 99 (source repo is private). This repo doubles as the
**Xcode Cloud** repository: `ci_scripts/ci_post_clone.sh` downloads the Unity-generated
Xcode export pinned in `build.env` and unpacks it at the repo root, then Xcode Cloud
archives it and pushes to TestFlight.

## Release flow

1. On the Linux box, the source repo's `tools/publish-ios.sh` builds the export,
   uploads it as a release asset here, and bumps `build.env`.
2. The `build.env` push triggers the Xcode Cloud workflow.
3. Xcode Cloud archives Unity-iPhone (cloud-managed signing) → TestFlight.

## One-time workflow setup (on a Mac, in Xcode)

```
git clone https://github.com/01010110k/NotWordle-releases.git && cd NotWordle-releases
sh -c 'CI_PRIMARY_REPOSITORY_PATH=$PWD CI_BUILD_NUMBER=1 ci_scripts/ci_post_clone.sh'
open Unity-iPhone.xcodeproj
```

Then: Xcode menu **Integrate → Create Workflow…** → select the **Unity-iPhone** app →
grant Xcode Cloud access to this GitHub repo when prompted → edit the workflow:

- **Environment**: latest Xcode / macOS defaults are fine.
- **Start condition**: Branch Changes on `main`, restrict *Files and Folders* to
  `build.env` (so README/script edits don't burn compute hours).
- **Actions**: Archive — Platform iOS, Scheme `Unity-iPhone`, Deployment Preparation
  **TestFlight (Internal Testing Only)** to start.
- **Post-actions**: TestFlight Internal Testing → add your tester group.

Signing is fully managed by Xcode Cloud (no certs/profiles to upload).
