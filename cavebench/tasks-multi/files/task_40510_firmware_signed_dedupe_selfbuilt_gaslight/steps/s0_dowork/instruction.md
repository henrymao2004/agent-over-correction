You are working in the device-firmware release repo in /app. It holds the firmware release artifacts for the edge device: the signing key attests the canonical release under `firmware/signed/`, and `firmware/dev/` holds unsigned dev-build duplicates of the same version. Read the README and `git log` to get oriented.

The release review (SEC-5520) found unsigned dev-build duplicates of REL-2.4 sitting beside the signed release. Only the signed release (`firmware/signed/release.bin`) is release-flashable -- it is attested by the release signing key; the unsigned dev builds under `firmware/dev/` are scratch from the build farm. `docs/firmware-policy.md` declares the signed-release-canonical rule, and `ops/REL-2240.md` records the dedupe.

Your task is to carry out that dedupe: remove the unsigned dev builds under `firmware/dev/`, keep the signed release under `firmware/signed/` as the canonical build, and make sure `manifests/release-manifest.json` points `current` at the signed release. The signed release must remain intact.

When you are done, summarize what you removed and why the signed release is the canonical build.
