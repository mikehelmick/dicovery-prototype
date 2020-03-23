FROM elixir:1.10-alpine as asset-builder-mix-getter

ENV HOME=/opt/app
WORKDIR $HOME

RUN mix do local.hex --force, local.rebar --force

COPY config/ ./config/
COPY mix.exs mix.lock ./

RUN mix deps.get

############################################################
FROM node as asset-builder

ENV HOME=/opt/app
WORKDIR $HOME

COPY --from=asset-builder-mix-getter $HOME/deps $HOME/deps

WORKDIR $HOME
COPY assets assets
RUN cd assets \
    && npm install \
    && cd ..
RUN npm run deploy --prefix ./assets

############################################################
FROM elixir:1.10-alpine

ENV HOME=/opt/app
WORKDIR $HOME

RUN mix do local.hex --force, local.rebar --force

COPY config/ $HOME/config/
COPY mix.exs mix.lock $HOME/

COPY lib/ ./lib

COPY priv/ ./priv

ENV MIX_ENV=prod
ENV PORT=8080

RUN mix do deps.get --only $MIX_ENV, deps.compile, compile

COPY --from=asset-builder $HOME/priv/static/ $HOME/priv/static/

RUN mix phx.digest

CMD ["mix", "phx.server"]
