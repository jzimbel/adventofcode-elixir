defmodule AdventOfCode.Solution.Year2024.Day23 do
  alias MapSet, as: Set

  use AdventOfCode.Solution.SharedParse

  @impl true
  def parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&Regex.run(~r/(\w+)-(\w+)/, &1, capture: :all_but_first))
    |> Enum.reduce(%{}, fn [node1, node2], acc ->
      acc
      |> Map.update(node1, Set.new([node2]), &Set.put(&1, node2))
      |> Map.update(node2, Set.new([node1]), &Set.put(&1, node1))
    end)
  end

  def part1(graph) do
    # k-clique problem, with k being 3 in this case
    # (and the extra condition that cliques must contain a "t_" node)
    graph
    |> Stream.filter(&match?({<<?t, _>>, _}, &1))
    |> Stream.flat_map(fn {tnode, neighbors} ->
      neighbors
      |> Enum.to_list()
      |> connected_pairs(graph)
      |> Enum.map(&Set.new([tnode | &1]))
    end)
    |> Stream.uniq()
    |> Enum.count()
  end

  def part2(graph) do
    # Bog-standard maximal clique problem
    graph
    |> maximal_clique()
    |> Enum.sort()
    |> Enum.join(",")
  end

  defp connected_pairs(nodes, graph, acc \\ [])

  defp connected_pairs([], _graph, acc), do: acc
  defp connected_pairs([_], _graph, acc), do: acc

  defp connected_pairs([node1 | nodes], graph, acc) do
    nodes
    |> Enum.filter(&Set.member?(graph[&1], node1))
    |> Enum.map(&[node1, &1])
    |> then(&connected_pairs(nodes, graph, &1 ++ acc))
  end

  defp maximal_clique(graph) do
    graph
    |> Enum.sort_by(fn {_node, neighbors} -> Set.size(neighbors) end, :desc)
    |> Enum.reduce_while(Set.new(), fn {gnode, _neighbors}, largest_clique ->
      clique_size = Set.size(largest_clique)

      cond do
        gnode in largest_clique ->
          {:cont, largest_clique}

        Set.size(graph[gnode]) + 1 <= clique_size ->
          {:halt, largest_clique}

        :else ->
          candidate = maximal_clique(graph, gnode, Set.new())
          {:cont, if(Set.size(candidate) > clique_size, do: candidate, else: largest_clique)}
      end
    end)
  end

  defp maximal_clique(graph, gnode, clique) do
    clique = Set.put(clique, gnode)

    graph[gnode]
    # Ignore neighbors we've already checked
    |> Enum.reject(&(&1 in clique))
    # Ignore neighbors that aren't connected to all members of this clique
    |> Enum.filter(&Set.subset?(clique, graph[&1]))
    |> Enum.reduce(clique, fn neighbor, largest_clique_acc ->
      # Ignore neighbors that have been added to the clique in previous reductions
      if neighbor in largest_clique_acc do
        largest_clique_acc
      else
        Enum.max_by([largest_clique_acc, maximal_clique(graph, neighbor, clique)], &Set.size/1)
      end
    end)
  end
end
