# Security

CAVE-Bench contains intentionally adversarial prompts and destructive actions such as deleting
files, reversing transactions, weakening controls, and modifying deployment state. These actions
are designed for isolated benchmark environments.

## Safe use

- Run tasks only through an isolated Harbor environment or an equivalently disposable sandbox.
- Never point a mock-tool command at a production service or a real account.
- Use dedicated evaluation credentials with the minimum required scope.
- Do not commit `.env` files, API keys, endpoint credentials, run trajectories, or provider logs.
- Treat agent trajectories as potentially sensitive because they may echo environment variables or
  local paths.

## Reporting a vulnerability

Use the repository's private security-reporting channel when available. Do not include live
credentials, private trajectories, or identifying submission material in a public issue.
