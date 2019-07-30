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
`./q3_reporter priv/examples/back-end-3.log`

## Options

- `--ranking` => Output ranking instead summary
- `--json` => Output result as json
- `--web` => Start a webserver with ranking and game summary

## Web mode

1. Run q3reporter in web mode
   `./q3_reporter --web priv/examples/back-end-3.log`

2. Open your browser in `http://localhost:8080/`

**Make sure `q3_reporter` script is in the same folder than `/templates` directory**

## Web customization

- You can define the port through env `PORT`, for example:
  `PORT=4000 q3_reporter --web priv/examples/back-end-3.log`
- You can customize the web templates in directory `templates/`
