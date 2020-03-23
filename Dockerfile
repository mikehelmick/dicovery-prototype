FROM elixir:1.10-alpine as build

ARG APP_NAME=discovery
ARG PHOENIX_SUBDIR=.
ENV MIX_ENV=prod

RUN mkdir /app
WORKDIR /app

# Install nodejs for asset processing.
RUN apk update \
  && apk --no-cache --update add nodejs nodejs-npm

RUN mix local.rebar --force \
  && mix local.hex --force

COPY mix.exs mix.lock ./
COPY config config
RUN mix deps.get
RUN mix deps.compile

# Run the static asset processing pipeline
COPY assets assets
COPY priv priv
RUN cd assets && npm install && npm run deploy
RUN mix phx.digest

COPY lib lib
RUN mix compile

RUN mix release

FROM alpine:3.9 AS app
RUN apk add --update bash openssl

RUN mkdir /app
WORKDIR /app

# Copy just the built artifact to the runnable image
COPY --from=build /app/_build/prod/rel/discovery ./
RUN chown -R nobody: /app
USER nobody
ENV RUNNER_LOG_DIR /var/log
CMD ["/app/bin/discovery", "start"]
