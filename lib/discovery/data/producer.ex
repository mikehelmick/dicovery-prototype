defmodule Discovery.Data.Producer do

  defstruct [
    :provider_name,
    :type,
    :producer_uri,
    :subscription_endpoint,
    :protocols,
    :subscription_ttl,
    :auth_scope,
    :specversion,
    :data_content_type,
    :data_schema,
    :data_schema_content,
    :source_structure,
    :subscription_config,
    :extensions
  ]

  use Accessible

  def new(name, type, params, exts) do
    %Discovery.Data.Producer{
      provider_name: name,
      type: type,
      producer_uri: "http://events.broker/#{name}",
      subscription_endpoint: "https://subscribe.events.broker/#{type}?provider=#{name}",
      protocols: ["http"],
      subscription_ttl: nil,
      auth_scope: "subscribe",
      specversion: "1.0",
      data_content_type: "application/json",
      data_schema: "https://schemas.in-the-cloud.dev/download/#{type}.json",
      data_schema_content: nil,
      source_structure: "/example/[id]",
      subscription_config: params,
      extensions: exts
    }
  end

  def producers() do
    %{
      "Cloud Storage" =>
        %{
        "com.storage.object.create" => new("Cloud Storage", "com.storage.object.create", [%{name: "path", type: "string"}], []),
        "com.storage.object.delete" => new("Cloud Storage", "com.storage.object.create", [%{name: "path", type: "string"}], [])
        },
      "Cloud SQL Database" =>
        %{
        "com.sql.row.insert" => new("Cloud SQL Database", "com.sql.row.insert", [%{name: "database", type: "string"}], []),
        "com.sql.row.update" => new("Cloud SQL Database", "com.sql.row.update", [%{name: "database", type: "string"}], [%{name: "row_key", type: "string"}]),
        "com.sql.row.delete" => new("Cloud SQL Database", "com.sql.row.delete", [%{name: "database", type: "string"}], [%{name: "row_key", type: "string"}]),
        "com.sql.table.create" => new("Cloud SQL Database", "com.sql.table.create", [%{name: "database", type: "string"}], []),
        "com.sql.table.drop" => new("Cloud SQL Database", "com.sql.table.drop", [%{name: "database", type: "string"}], [])
        },
      "IOT Broker" =>
        %{
        "com.iot.message" => new("IOT Broker", "com.iot.message", [%{name: "device", type: "string"}], []),
        "com.iot.device" => new("IOT Broker", "com.iot.message", [], [%{name: "device_name", type: "string"}])
        },
      "GitHub" =>
        %{
        "com.github.pullrequest" => new("GitHub", "com.github.pullrequest", [%{name: "repository", type: "string"}], []),
        "com.github.merge" => new("GitHub", "com.github.pullrequest", [%{name: "repository", type: "string"}], []),
        "com.github.branch" => new("GitHub", "com.github.pullrequest", [%{name: "repository", type: "string"}], [])
        },
      "Other Cloud Storage" =>
        %{
        "com.storage.object.create" => new("Other Cloud Storage", "com.storage.object.create", [%{name: "path", type: "string"}], []),
        "com.storage.object.delete" => new("Other Cloud Storage", "com.storage.object.delete", [%{name: "path", type: "string"}], [])
        },
      "Cloud Pub/Sub System" =>
        %{
        "com.pubsub.publish" => new("Cloud Pub/Sub System", "com.pubsub.publish", [%{name: "partition", type: "string"}], [])
        }
    }
  end

  def resolve(_, %{provider: provider, type: type}, _) do
    case Map.get(producers(), provider) do
      nil -> {:error, "Can't find provider: `#{provider}`"}
      types ->
        case Map.get(types, type) do
          nil -> {:error, "Can't find type: `#{type}` for provider `#{provider}`"}
          data -> {:ok, data}
        end
    end
  end
  def resolve(_, _, _) do
    {:error, "Required parameters missing."}
  end

  def gen_sources(0, _, list), do: list
  def gen_sources(n, item, list) do
    gen_sources(n - 1, item, list ++ ["#{item}#{n}"])
  end

  def all_sources() do
    gen_sources(10, "/alpha/", []) ++
    gen_sources(20, "/beta/", []) ++
    gen_sources(5, "/gamma/", [])
  end

  def sources(_, %{source_prefix: prefix}, _) do
    d_prefix = String.downcase(prefix)
    results = Enum.filter(all_sources(),
      fn(x) ->
        String.starts_with?(String.downcase(x), d_prefix)
      end)
      |> Enum.map(fn x -> %{source: x} end)
    {:ok, results}
  end
  def sources(parent, m = %{}, resolver) do
    sources(parent, Map.put(m, :source_prefix, ""), resolver)
  end

end
