defmodule Discovery.Data.Type do

  defstruct [
    :name,
    :specversion,
    :data_content_type,
    :schema,
    :data_schema_content,
    :providers
  ]

  use Accessible

  def type(type_name, providers) when is_list(providers) do
    %Discovery.Data.Type{
      name: type_name,
      specversion: "1.0",
      data_content_type: "application/json",
      schema: "http://schemas.in-the-cloud.dev/download/#{type_name}.json",
      providers: providers
    }
  end

  def types() do
    data = [
      # for 1, 5
      type("com.storage.object.create", ["1", "5"]),
      type("com.storage.object.delete", ["1", "5"]),
      # for 2
      type("com.sql.row.insert", ["2"]),
      type("com.sql.row.update", ["2"]),
      type("com.sql.row.delete", ["2"]),
      type("com.sql.table.create", ["2"]),
      type("com.sql.table.drop", ["2"]),
      # for 3
      type("com.iot.message", ["3"]),
      type("com.iot.device", ["3"]),
      # for 4
      type("com.github.pullrequest", ["4"]),
      type("com.github.merge", ["4"]),
      type("com.github.branch", ["4"]),
      # for 6
      type("com.pubsub.publish", ["6"])
    ]
   data
  end

  def type_map() do
    types() |> List.foldl(%{}, fn t, m -> Map.put(m, t[:name], t) end)
  end

  def by_name(_, %{name: term}, _) do
    d_term = String.downcase(term)
    # Search through matching providers by name.
    results = Enum.filter(types(),
        fn(x) -> String.downcase(x[:name]) == d_term end)
    case results do
      [r] -> {:ok, r}
      [] -> {:error, "Type named '#{inspect(term)}' was not found."}
    end
  end
  def by_name(_, _, _) do
    {:error, "Type name requred to load type."}
  end

end
