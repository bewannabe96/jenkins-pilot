#/bin/bash

git tag --sort=-v:refname --list | grep -E '^v(0|[0-9]+)\.(0|[0-9]+)\.(0|[0-9]+)$' | head -n 1