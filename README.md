<div align="center">

# asdf-codon [![Build](https://github.com/3w36zj6/asdf-codon/actions/workflows/build.yml/badge.svg)](https://github.com/3w36zj6/asdf-codon/actions/workflows/build.yml) [![Lint](https://github.com/3w36zj6/asdf-codon/actions/workflows/lint.yml/badge.svg)](https://github.com/3w36zj6/asdf-codon/actions/workflows/lint.yml)

[codon](https://github.com/3w36zj6/codon) plugin for the [asdf version manager](https://asdf-vm.com).

</div>

# Contents

- [Dependencies](#dependencies)
- [Install](#install)
- [Contributing](#contributing)
- [License](#license)

# Dependencies

**TODO: adapt this section**

- `bash`, `curl`, `tar`, and [POSIX utilities](https://pubs.opengroup.org/onlinepubs/9699919799/idx/utilities.html).
- `SOME_ENV_VAR`: set this environment variable in your shell config to load the correct version of tool x.

# Install

Plugin:

```shell
asdf plugin add codon
# or
asdf plugin add codon https://github.com/3w36zj6/asdf-codon.git
```

codon:

```shell
# Show all installable versions
asdf list-all codon

# Install specific version
asdf install codon latest

# Set a version globally (on your ~/.tool-versions file)
asdf global codon latest

# Now codon commands are available
codon --help
```

Check [asdf](https://github.com/asdf-vm/asdf) readme for more instructions on how to
install & manage versions.

# Contributing

Contributions of any kind welcome! See the [contributing guide](contributing.md).

[Thanks goes to these contributors](https://github.com/3w36zj6/asdf-codon/graphs/contributors)!

# License

See [LICENSE](LICENSE) © [3w36zj6](https://github.com/3w36zj6/)
