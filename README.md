# shell.yazi

Use any shell as the default yazi shell prompt.

# Installation

```bash
## For Unix platforms
git clone https://github.com/KKV9/shell.yazi.git ~/.config/yazi/plugins/shell.yazi

## For Windows
git clone https://github.com/KKV9/shell.yazi.git %AppData%\yazi\config\plugins\shell.yazi

## Or with yazi plugin manager
ya pack -a KKV9/shell
```

## Usage

### Quickstart

- Add this to your `keymap.toml`:

```toml
[[manager.prepend_keymap]]
on = [ ";" ]
run = "plugin shell"
desc = "Default shell"
[[manager.prepend_keymap]]
on = [ ":" ]
run = "plugin shell --args=--block"
desc = "Default shell with blocking"
```

### More example use cases

```toml
[[manager.prepend_keymap]]
on = [ ";" ]
run = "plugin shell --args=zsh"
desc = "zsh shell"
```

```toml
[[manager.prepend_keymap]]
on = [ ",", "p" ]
run = "plugin shell --args='nu \"ls | sort-by \" --block'"
desc = "ls table in nu sort by ...?"
```

```toml
[[manager.prepend_keymap]]
on = [ "c", "e" ]
run = "plugin shell --args='fish \"echo example command with --block and --confirm flags ; read\" --block --confirm'"
desc = "Blocking echo command with fish"
```

**NOTE:** The first argument must be either "auto" or the shell name e.g. "fish". Multiple yazi arguments must be quoted with single quotes.

# Features

- Open any shell as your default yazi shell.
- When shell is set to `auto` or unspecified, will read from $SHELL environment variable.
- Usage of aliases is supported in most shells.
- Supports default yazi shell arguments `[run]` `--confirm` and `--block`.
- `[run]` shell variables/positional arguments supported in fish and posix compliant shells. 
- Fixes some bugs associated with run variables.
 
# Run variables

| Variable      | Shells        | Value              |
| ------------- | ------------- | ------------------ |
| `$*` or `$@`  | Posix only    | Selected or hovered|
| `$n`          | Posix only    | n-th Selected      |
| `$argv`       | Fish only     | Selected or hovered|
| `$argv[n]`    | Fish only     | n-th Selected      |
| `$0`          | Posix and fish| Hovered            |

**NOTE:** Example: `$2` returns second selected file in posix. `$argv[1]` returns first selected file or hovered if nothing is selected in fish.
