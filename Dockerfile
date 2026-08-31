FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN flutter build web --release --no-wasm-dry-run

FROM caddy:2-alpine

WORKDIR /app

COPY Caddyfile ./
RUN caddy fmt Caddyfile --overwrite

COPY --from=build /app/build/web ./build/web

CMD ["caddy", "run", "--config", "Caddyfile", "--adapter", "caddyfile"]
