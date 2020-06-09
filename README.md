# Discovery

Running demo at [discovery.in-the-cloud.dev](https://discovery.in-the-cloud.dev)

some example GraphQL queries you can run.

1. General Search

```graphql
{
  search(matching: "storage") {
    __typename
    ... on Provider {
      name,
      types {
        name
      }
    }
    ... on Type {
      name,
      providers {
        name
      }
    }
  }
}
```

2. Get a single provider's types by name

```graphql
{
  provider(name: "Cloud Storage") {
    name,
    description,
    types {
        name
    }    
  }
}
```

3. Get all providers of aa single event type.

```GraphQL
{
  type(name: "com.storage.object.create") {
    name,
    specversion,
    dataSchema,
    dataContentType,
    providers {
      name
    }
  }
}
```

4. Get the complete details for a single producer, type tuple.

```GraphQL
{
  producer(provider: "Cloud Storage", type: "com.storage.object.create") {
    authScope
    dataContentType
    dataSchema
    extensions {
      name
    }
    protocols
    providerName
    sourceStructure
    specversion
    subscriptionConfig {
      name
    }
    subscriptionEndpoint
    subscriptionTtl
    type
  }
}
```

# Run Locally

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).
