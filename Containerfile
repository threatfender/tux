ARG ELIXIR_VERSION=1.19.2-alpine
FROM elixir:${ELIXIR_VERSION}

# Set workdir
WORKDIR /app

# Create a non-root user
RUN adduser -D -u 1000 tester

# Update workdir permissions
RUN chown tester:tester /app

# Copy project
COPY  --chown=tester:tester mix.exs  ./
COPY  --chown=tester:tester mix.lock ./
COPY  --chown=tester:tester lib      ./lib
COPY  --chown=tester:tester test     ./test

# Switch to the new user
USER tester

# Install build tools
RUN mix local.hex --force

# Install required dependencies
RUN mix deps.get --only test

# Run tests with coverage
CMD ["mix", "test", "--cover"]
