# Nebula runner hardening README additions

This README supplements tools/ci/README-runner.md with instructions for signed-tag verification and systemd unit installation.

Signed-tag verification
- To require that builds are only produced from signed tags (or commits pointed-to by signed tags), place the public GPG key used to sign tags at:
  /etc/nebula-build-signing-key.pub
- The hardened wrapper will import that key into a temporary GNUPGHOME and run `git verify-tag` on the tag, or look for signed tags that point to the current commit. If verification fails the build is aborted.
- Ensure `gnupg` is installed on the runner host (bootstrap script should install `gnupg`).

Install systemd units (on the self-hosted runner host):
- Copy the unit files into /etc/systemd/system/ and enable the timers:
  sudo cp tools/ci/systemd/nebula-cleanup.service /etc/systemd/system/
  sudo cp tools/ci/systemd/nebula-cleanup.timer /etc/systemd/system/
  sudo cp tools/ci/systemd/nebula-runner-update.service /etc/systemd/system/
  sudo cp tools/ci/systemd/nebula-runner-update.timer /etc/systemd/system/

  sudo systemctl daemon-reload
  sudo systemctl enable --now nebula-cleanup.timer
  sudo systemctl enable --now nebula-runner-update.timer

Logrotate
- Copy tools/ci/nebula-logrotate.conf to /etc/logrotate.d/nebula-build to rotate wrapper logs.

