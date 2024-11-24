# Advent of Code Elixir Solutions

Solutions and tests for [Advent of Code][aoc] puzzles.

Built with the [Advent of Code Elixir Starter][aoc-starter].

Tweaked substantially from there.

> [!NOTE]
> Disclaimer: Not all of my solution code is idiomatic Elixir—for some
> puzzles, I've taken unusual approaches, or written extra-dense code, or
> optimized for performance, or tried new standard library features with which
> I'm not very familiar.\
> Readability is not always a priority.

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
mix advent.solve -d${DAY} [-p${1 | 2}] [-y${YEAR}] [--bench]
```

and tests with
```shell
mix test
```

either directly in your local terminal, or in VSCode's terminal pane while
connected to a dev container as described below.

## Get started in a self-contained environment

<img width="1912" alt="Screenshot of the project running in GitHub Codespaces" src="https://github.com/user-attachments/assets/8b2e5625-c9dc-489b-99a3-39b7a8888c00">

This project can optionally run in a dev container for remote development.\
You have two options:

### :octocat: Run in your browser using GitHub Codespaces

1. Go to the landing page of this repo.
1. Click the `<> Code` drop-down menu, select the Codespaces tab, and click the
   big green button.
1. Wait for the Codespace to build. It should be relatively speedy if you build
   from the main branch, as I have prebuilds configured for that.
1. Once the in-browser editor activates, follow the steps from [Usage](#usage)
   to enable puzzle downloads and run a solution. (You can use
   <kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>`</kbd> to open a terminal pane.)

   If you're running on a fork of the repository, you can also edit as you
   please.

### :whale: Using Visual Studio Code + Docker Desktop

Requires Docker Desktop or an alternative Docker-compliant CLI, like podman.

Simply open the project directory locally in VS Code. It will show a popup
asking if you want to use the Dev Container. It will then guide you through
getting set up, building the container image, and connecting to the running dev
container.

[aoc]: https://adventofcode.com/
[aoc-starter]: https://github.com/mhanberg/advent-of-code-elixir-starter
[docker]: https://www.docker.com/products/docker-desktop
[dev-container]:
    https://code.visualstudio.com/docs/devcontainers/create-dev-container
