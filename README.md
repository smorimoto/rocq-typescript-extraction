# rocq-typescript-extraction

A Rocq plugin that extracts Rocq definitions to TypeScript ES modules.

Supports inductive types, records, recursive functions, modules, and functors. Generated code uses erasable TypeScript syntax and is checked with strict TypeScript settings. See the [limitations](docs/encoding.md#limitations) before using it in a project.

## Documentation

- [Getting started](docs/getting-started.md): installation and a first extraction.
- [Extraction guide](docs/extraction.md): commands, presets, and custom mappings.
- [TypeScript reference](docs/encoding.md): generated APIs, data representations, and limitations.
- [Contributing](CONTRIBUTING.md): development setup, tests, and benchmarks.

## License

[ISC](LICENSE). Third-party dependencies retain their own licenses; see the [dependency notes](CONTRIBUTING.md#third-party-dependencies).
