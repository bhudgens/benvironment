# Temporary Git Config Enforcement After Decrypt

## Status

Accepted, temporary.

## Context

Some environments have an incorrect global Git email. The Git email and
Bitwarden login are intentionally separate encrypted values, stored as
`GIT_EMAIL` and `BW_USERNAME`.

Forcing Git config during shell startup would require decrypting `GIT_EMAIL`
while loading the environment. That would bring back the unwanted login-time
decode prompt.

## Decision

When any named encrypted value is needed, `dec_value` decrypts all named values
and caches the decrypted values in runtime storage. Immediately after that
decrypt succeeds, benvironment temporarily enforces:

```bash
git config --global user.email "$(dec_value GIT_EMAIL)"
git config --global user.name "$configured_git_name"
```

The hook lives in `encrypted-values` as `_benvironment_after_decrypt`.

## Why This Is Temporary

This is a repair mechanism for environments already carrying bad Git config.
It is tied to decrypt usage because `keyme` is used often and already needs
decrypted values, so this fixes Git config without adding startup prompts.

Once affected environments have converged, remove `_benvironment_after_decrypt`
and this ADR, or replace the behavior with an explicit command such as
`fix-git-identity`.
