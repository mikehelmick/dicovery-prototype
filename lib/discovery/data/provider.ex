defmodule Discovery.Data.Provider do

  defstruct [
    :id,
    :name,
    :description
  ]

  use Accessible

  def provider(id, name, description) do
    %Discovery.Data.Provider{id: id, name: name, description: description}
  end

  def list() do
    data = [
      provider("1", "Cloud Storage", "Cloud Blob Storage"),
      provider("2", "Cloud SQL Database", "Cloud SQL Database"),
      provider("3", "IOT Broker", "IOT Broker"),
      provider("4", "GitHub", "Events from github.com repositories"),
      provider("5", "Other Cloud Storage", "A differe cloud blob storage"),
      provider("6", "Cloud Pub/Sub System", "Messages from your pub/sub system")
    ]
    data
  end

  def providers_for_type(type, _, _) do
    type_providers = Map.get(Discovery.Data.Type.type_map(), type[:name])[:providers]
    IO.puts("TYPE providers: #{inspect(type_providers)}")
    providers = list()
      |> Enum.filter(fn p -> Enum.member?(type_providers, p[:id]) end)
    IO.puts("providers_for_type: #{inspect(type)} are #{inspect(providers)}")
    {:ok, providers}
  end

  def types_for_provider(provider, _, _) do
    IO.puts("types_for_provider: '#{inspect(provider)}'")
    types = Discovery.Data.Type.types()
      |> Enum.filter(fn a -> Enum.member?(a[:providers], provider[:id]) end)
      |> Enum.map(fn a -> Map.delete(a, :providers) end)
    IO.puts("types: #{inspect(types)}")
    {:ok, types}
  end

  def by_name(_, %{name: term}, _) do
    d_term = String.downcase(term)
    # Search through matching providers by name.
    results = Enum.filter(list(),
        fn(x) -> String.downcase(x[:name]) == d_term end)
    case results do
      [r] -> {:ok, r}
      [] -> {:error, "Provider named '#{inspect(term)}' was not found."}
    end
  end

  defp common_search_filter(items, term, order) do
    d_term = String.downcase(term)
    # Search through matching providers by name.
    results = Enum.filter(items,
      fn(x) ->
        String.contains?(String.downcase(x[:name]), d_term)
      end)
     |> Enum.sort(fn(a,b) ->
                     String.downcase(a[:name]) <= String.downcase(b[:name])
                   end)
    results =
      case order do
        :asc -> results
        :desc -> Enum.reverse(results)
      end
    results
  end

  def resolve_types(_, %{matching: term, order: order}, _) do
    results = common_search_filter(Discovery.Data.Type.types(), term, order)
    {:ok, results}
  end
  def resolve_types(a, m = %{matching: _term}, b) do
    resolve_types(a, Map.put(m, :order, :asc), b)
  end
  def resolve_types(a, m = %{order: _order}, b) do
    resolve_types(a, Map.put(m, :term, ""), b)
  end
  def resolve_types(_, _, _) do
    {:ok, Discovery.Data.Type.types()}
  end

  def resolve_providers(_, %{matching: term, order: order}, _) do
    results = common_search_filter(list(), term, order)
    {:ok, results}
  end
  def resolve_providers(a, m = %{matching: _term}, b) do
    resolve_providers(a, Map.put(m, :order, :asc), b)
  end
  def resolve_providers(a, m = %{order: _order}, b) do
    resolve_providers(a, Map.put(m, :term, ""), b)
  end
  def resolve_providers(_, _, _) do
    {:ok, list()}
  end

  def resolve(_, %{matching: term, order: order}, _) do
    results = common_search_filter(list() ++ Discovery.Data.Type.types(), term, order)
    {:ok, results}
  end
  def resolve(a, m = %{matching: _term}, b) do
    resolve(a, Map.put(m, :order, :asc), b)
  end
  def resolve(a, m = %{order: _order}, b) do
    resolve(a, Map.put(m, :term, ""), b)
  end
  def resolve(_, _, _) do
    {:ok, list()}
  end

  def sources(_, _, _), do: []

  def extensions(_, _, _) do
    {:ok, []}
  end

end
