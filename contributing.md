# Contributing

Testing Locally:

```shell
asdf plugin test <plugin-name> <plugin-url> [--asdf-tool-version <version>] [--asdf-plugin-gitref <git-ref>] [test-command*]

asdf plugin test codon https://github.com/3w36zj6/asdf-codon.git "codon --help"
```

Tests are automatically run in GitHub Actions on push and PR.
