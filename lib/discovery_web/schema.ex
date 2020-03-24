defmodule DiscoveryWeb.Schema do
  use Absinthe.Schema

  query do
    field :search, list_of(:search_result) do
      arg :matching, :string
      arg :order, :sort_order
      resolve &Discovery.Data.Provider.resolve/3
    end
    field :providers, list_of(:provider) do
      arg :matching, :string
      arg :order, :sort_order
      resolve &Discovery.Data.Provider.resolve_providers/3
    end
    field :provider, :provider do
      arg :name, :string
      resolve &Discovery.Data.Provider.by_name/3
    end
    field :types, list_of(:type) do
      arg :matching, :string
      arg :order, :sort_order
      resolve &Discovery.Data.Provider.resolve_types/3
    end
    field :type, :type do
      arg :name, :string
      resolve &Discovery.Data.Type.by_name/3
    end
    field :producer, list_of(:producer) do
      arg :provider, type: non_null(:string)
      arg :type, type: non_null(:string)
      resolve &Discovery.Data.Producer.resolve/3
    end
  end

  union :search_result do
    types [:provider, :type]
    resolve_type fn
      %Discovery.Data.Provider{}, _ -> :provider
      %Discovery.Data.Type{}, _ -> :type
      _, _ -> nil
    end
  end

  enum :sort_order do
    value :asc
    value :desc
  end

  object :provider do
    field :id, :id
    field :name, :string
    field :description, :string
    field :types, list_of(:type) do
      resolve &Discovery.Data.Provider.types_for_provider/3
    end
  end

  object :type do
    field :name, :string
    field :specversion, :string
    field :data_content_type, :string
    field :data_schema, :string
    field :data_schema_content, :string
    field :providers, list_of(:provider) do
      resolve &Discovery.Data.Provider.providers_for_type/3
    end
  end

  object :producer do
    field :provider_name, :string
    field :type, :string
    field :producer_uri, :string
    field :subscription_endpoint, :string
    field :protocols, list_of(:string)
    field :subscription_ttl, :integer
    field :auth_scope, :string
    field :specversion, :string
    field :data_content_type, :string
    field :data_schema, :string
    field :data_schema_content, :string
    field :source_structure, :string
    field :sources, list_of(:source) do
      arg :source_prefix, :string
      resolve &Discovery.Data.Producer.sources/3
    end
    field :subscription_config, list_of(:parameters)
    field :extensions, list_of(:extension)
  end

  object :parameters do
    field :name, :string
    field :type, :string
    field :description, :string
  end

  object :extension do
    field :name, :string
    field :type, :string
    field :description, :string
  end

  object :source do
    field :source, :string
  end
end
