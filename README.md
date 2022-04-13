# Q3Reporter

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
