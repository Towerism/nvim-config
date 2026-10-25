---
documentLanguage: en
---

# Glossary

One entry per term: definition, boundaries, one resolved ambiguity. Agents write here the moment a term is settled. Vocabulary here is law for all specs, tickets, and code naming. Ship-specific terms only: a concept any sea chart carries does not get an entry.

## LazyVim base
- Definition: the upstream `LazyVim/LazyVim` distribution that `lua/config/lazy.lua` imports via `{ "LazyVim/LazyVim", import = "lazyvim.plugins" }`.
- Boundary: is the upstream defaults, not this repo's code. Fixing it means overriding it from `lua/plugins/`, never editing upstream.
- Avoid: "starter" (that is the `lazy` remote, `LazyVim/starter`, the template this repo was cut from).
- Resolved ambiguity: `lazy` the git remote (template) vs `lazy.nvim` the plugin manager; they are unrelated.

## fix spec
- Definition: a file in `lua/plugins/` named `<plugin>-fix.lua` that patches a plugin or Neovim incompatibility (e.g. `treesitter-fix.lua`, `noice-fix.lua`).
- Boundary: is a workaround that opens with a comment naming the Neovim version and the exact error it silences; is not a feature or preference.
- Avoid: "patch", "hack".
- Resolved ambiguity: a fix spec is deleted once upstream resolves the error, so its header comment must say what to check before deleting.
