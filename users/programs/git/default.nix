{ ... }:

# Shared, identity-free git config. Lives in the PUBLIC cfg library, so it holds
# only portable settings (aliases, tools, defaults) — never user.name/user.email.
# Each machine sets its own identity via programs.git.settings.user in its
# private flake (e.g. conf, or the machine template). settings merges across
# modules, so the identity attrs land alongside these.
{
  programs.git = {
    enable = true;

    # delta: syntax-highlighted, readable git diffs. This HM option installs the
    # `delta` package and wires it as git's pager (core.pager) + the interactive
    # diff filter, and writes the [delta] config below — no separate package or
    # core.pager line needed. Doesn't conflict with diff/merge.tool = vimdiff
    # (those drive `git difftool`/`mergetool`; delta only formats pager output).
    delta = {
      enable = true;
      options = {
        navigate = true; # n / N to jump between diff hunks in the pager
        line-numbers = true;
      };
    };

    settings = {
      alias = {
        st = "status -s";
        ci = "commit -m";
        cm = "commit -am";
        br = "branch";
        co = "checkout";
        unstage = "reset HEAD";
        last = "log -1 HEAD";
        df = "diff";
        dc = "diff --cached";
        lo = "log --oneline --graph --decorate";
        loa = "log --oneline --graph --decorate --all";
        ls = "ls-files";
        ign = "ls-files -o -i --exclude-standard";
        ahead = "log origin/main..HEAD --oneline";
      };

      color.ui = true;
      credential.helper = "cache --timeout=3600";
      diff.tool = "vimdiff";
      difftool.prompt = false;
      merge.tool = "vimdiff";
      mergetool = {
        prompt = false;
        keepBackup = false;
      };
      http.postBuffer = 524288000;
      init.defaultBranch = "main";
      pull.ff = "only";
      push.default = "matching";
    };
  };
}
