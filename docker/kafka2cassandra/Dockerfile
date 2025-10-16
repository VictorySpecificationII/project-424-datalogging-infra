# Use Go 1.25.1 as base
FROM golang:1.25.1-alpine AS builder

WORKDIR /app

# Copy Go modules manifests
COPY go.mod go.sum ./
RUN go mod download

# Copy the source code
COPY main.go ./

# Build the binary
RUN go build -o telemetry-consumer main.go

# Final image
FROM alpine:3.18

WORKDIR /app

# Copy the binary from builder
COPY --from=builder /app/telemetry-consumer .

# Use a non-root user (optional)
RUN adduser -D appuser
USER appuser

# Run the Go consumer
CMD ["./telemetry-consumer"]
