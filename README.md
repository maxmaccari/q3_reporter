# Q3Reporter
![Format](https://github.com/maxmaccari/q3_reporter/actions/workflows/format.yml/badge.svg)
![Credo](https://github.com/maxmaccari/q3_reporter/actions/workflows/credo.yml/badge.svg)
![Credo](https://github.com/maxmaccari/q3_reporter/actions/workflows/dialyzer.yml/badge.svg)
![Tests](https://github.com/maxmaccari/q3_reporter/actions/workflows/tests.yml/badge.svg)
![Coverage](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/maxmaccari/d32b12d3978f7d2a6b27b6ec5c275040/raw/q3_reporter_coverage.json)

**Generate a report base on a Quake 3 log**

## Requirements

- `erlang 19` or above
- `elixir 1.7` or above

## Setup

1. Install mix dependencies
   `mix deps.get`

2. Compile the project
   `mix compile`

3. Generate cli executable
   `mix escript.build`

## Usage

You can run the cli by running
`./q3_reporter [options] <filename>`

For example:
`./q3_reporter examples/back-end-3.log`

## Options

- `--ranking` => Output ranking instead summary
- `--json` => Output result as json
