# Advent of Code Elixir Solutions

Solutions and tests for [Advent of Code](https://adventofcode.com/) puzzles.

Built with the [Advent of Code Elixir Starter](https://github.com/mhanberg/advent-of-code-elixir-starter).

Tweaked substantially from there.

## Usage

Enable the automatic puzzle input downloader by creating a `config/secrets.exs`
file containing the following:

```elixir
import Config

config :advent_of_code, AdventOfCode.Input,
  allow_network?: true,
  session_cookie: "..." # paste your AoC session cookie value here
```

Fetch dependencies with
```shell
mix deps.get
```

Generate a set of solution and test files for a new year of puzzles with
```shell
mix advent.gen -y${YEAR}
```

Now you can run the solutions with
```shell
mix advent.solve -d${DAY} -p${1 | 2} [-y${YEAR}] [--bench]
```

and tests with
```shell
mix test
```

either directly in your local terminal, or in VSCode's terminal pane while connected to the Docker container described below.

### Get started coding with zero configuration

#### Using Visual Studio Code

1. [Install Docker Desktop](https://www.docker.com/products/docker-desktop)
1. Open project directory in VS Code
1. Press F1, and select `Remote-Containers: Reopen in Container...`
1. Wait a few minutes as it pulls image down and builds Dev Container Docker image (this should only need to happen once unless you modify the Dockerfile)
    1. You can see progress of the build by clicking `Starting Dev Container (show log): Building image` that appears in bottom right corner
    1. During the build process it will also automatically run `mix deps.get`
1. Once complete VS Code will connect your running Dev Container and will feel like your doing local development
1. If you would like to use a specific version of Elixir change the `VARIANT` version in `.devcontainer/devcontainer.json`
1. If you would like more information about VS Code Dev Containers check out the [dev container documentation](https://code.visualstudio.com/docs/remote/create-dev-container/?WT.mc_id=AZ-MVP-5003399)

#### Compatible with Github Codespaces
1. If you don't have Github Codespaces beta access, sign up for the beta https://github.com/features/codespaces/signup
1. On GitHub, navigate to the main page of the repository.
1. Under the repository name, use the  Code drop-down menu, and select Open with Codespaces.
1. If you already have a codespace for the branch, click  New codespace.
