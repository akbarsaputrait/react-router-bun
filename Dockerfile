# Stage 1: Development dependencies
FROM oven/bun:latest as development-dependencies-env
COPY . /app
WORKDIR /app
RUN bun install

# Stage 2: Production dependencies
FROM oven/bun:latest as production-dependencies-env
COPY ./package.json bun.lockb /app/
WORKDIR /app
RUN bun install --production

# Stage 3: Build
FROM oven/bun:latest as build-env
COPY . /app/
COPY --from=development-dependencies-env /app/node_modules /app/node_modules
WORKDIR /app
RUN bun run build

# Stage 4: Production environment
FROM oven/bun:latest
COPY ./package.json bun.lockb server.js /app/
COPY --from=production-dependencies-env /app/node_modules /app/node_modules
COPY --from=build-env /app/build /app/build
WORKDIR /app
CMD ["bun", "run", "start"]
