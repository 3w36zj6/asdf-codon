#!/usr/bin/env bash

set -euo pipefail

# Codon upstream repository.
GH_REPO="https://github.com/exaloop/codon"
TOOL_NAME="codon"
TOOL_TEST="codon --help"

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

# NOTE: You might want to remove this if codon is not hosted on GitHub releases.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

resolve_version() {
	local version
	version="$1"
	if [[ "$version" == "latest" ]]; then
		version="$(list_all_versions | sort_versions | tail -n1 | xargs echo)"
		if [ -z "$version" ]; then
			fail "Could not determine the latest $TOOL_NAME version."
		fi
	fi
	printf "%s\n" "$version"
}

get_os() {
	local os
	os="$(uname -s | awk '{print tolower($0)}')"
	case "$os" in
	linux | darwin)
		printf "%s\n" "$os"
		;;
	*)
		fail "Pre-built binaries only exist for Linux and macOS. Detected OS: $os"
		;;
	esac
}

get_arch() {
	local arch
	arch="$(uname -m)"
	case "$arch" in
	x86_64 | aarch64)
		printf "%s\n" "$arch"
		;;
	amd64)
		printf "%s\n" "x86_64"
		;;
	arm64)
		printf "%s\n" "aarch64"
		;;
	*)
		fail "Unsupported architecture for pre-built Codon binaries: $arch"
		;;
	esac
}

determine_asset_arch() {
	local os arch
	os="$1"
	arch="$2"
	if [[ "$os" == "darwin" && "$arch" == "aarch64" ]]; then
		printf "arm64\n"
	else
		printf "%s\n" "$arch"
	fi
}

normalize_tag() {
	local version
	version="$1"
	if [[ "$version" == v* ]]; then
		printf "%s\n" "$version"
	else
		printf "v%s\n" "$version"
	fi
}

list_github_releases() {
	local page url
	page=1
	while :; do
		url="https://api.github.com/repos/exaloop/codon/releases?per_page=100&page=$page"

		# Extract tag_name values without requiring jq.
		# Example: "tag_name": "v0.18.0"
		local tags
		tags="$(curl "${curl_opts[@]}" "$url" |
			grep -oE '"tag_name"[[:space:]]*:[[:space:]]*"[^"]+"' |
			sed -E 's/.*"tag_name"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/' || true)"

		if [ -z "$tags" ]; then
			break
		fi

		printf "%s\n" "$tags"
		page=$((page + 1))
	done
}

list_all_versions() {
	# Codon versions are published as GitHub Releases.
	# Output versions without the leading "v" (asdf convention).
	list_github_releases |
		sed 's/^v//' |
		grep -E '^[0-9]'
}

download_release() {
	local version filename url resolved_version
	version="$1"
	filename="$2"
	local os arch tag asset
	resolved_version="$(resolve_version "$version")"
	os="$(get_os)"
	arch="$(get_arch)"
	tag="$(normalize_tag "$resolved_version")"
	local asset_arch
	asset_arch="$(determine_asset_arch "$os" "$arch")"
	asset="codon-$os-$asset_arch.tar.gz"
	url="$GH_REPO/releases/download/$tag/$asset"

	echo "* Downloading $TOOL_NAME release $resolved_version..."
	curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="$3"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		mkdir -p "$install_path"
		cp -r "$ASDF_DOWNLOAD_PATH"/* "$install_path/"

		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/bin/$tool_cmd" || fail "Expected $install_path/bin/$tool_cmd to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
