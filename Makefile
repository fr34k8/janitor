IMAGE   := abali/janitor

VERSION := $(shell git describe --tags --always)
BUILD   := $(shell date '+%FT%T%z')
COMMIT  := $(shell git rev-parse --short HEAD)

build:
	@go build -ldflags="-X main.version=$(VERSION) -X main.build=$(BUILD) -X main.commit=$(COMMIT)"

.PHONY: test
test:
	@go test -timeout 60s ./...

static_build:
	@CGO_ENABLED=0 go build -ldflags="-X main.version=$(VERSION) -X main.build=$(BUILD) -X main.commit=$(COMMIT)"

LDFLAGS := -X main.version=$(VERSION) -X main.build=$(BUILD) -X main.commit=$(COMMIT)

.PHONY: build-all
build-all:
	@mkdir -p dist
	GOOS=linux   GOARCH=amd64 CGO_ENABLED=0 go build -ldflags="$(LDFLAGS)" -o dist/janitor-linux-amd64
	GOOS=linux   GOARCH=arm   GOARM=5 CGO_ENABLED=0 go build -ldflags="$(LDFLAGS)" -o dist/janitor-linux-arm
	GOOS=linux   GOARCH=arm64 CGO_ENABLED=0 go build -ldflags="$(LDFLAGS)" -o dist/janitor-linux-arm64
	GOOS=windows GOARCH=amd64 CGO_ENABLED=0 go build -ldflags="$(LDFLAGS)" -o dist/janitor-windows-amd64.exe
	GOOS=darwin  GOARCH=amd64 CGO_ENABLED=0 go build -ldflags="$(LDFLAGS)" -o dist/janitor-darwin-amd64
	GOOS=darwin  GOARCH=arm64 CGO_ENABLED=0 go build -ldflags="$(LDFLAGS)" -o dist/janitor-darwin-arm64

.PHONY: docker
docker:
	docker build . -t $(IMAGE)

.PHONY: publish
publish:
	@docker buildx create --use --name=crossplat --node=crossplat && \
	docker buildx build \
		--platform linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64 \
		--output "type=image,push=true" \
		--tag $(IMAGE):$(VERSION) \
		--tag $(IMAGE):latest \
		.

.PHONY: publish-dev
publish-dev:
	@docker buildx create --use --name=crossplat --node=crossplat && \
	docker buildx build \
		--platform linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64 \
		--output "type=image,push=true" \
		--tag $(IMAGE):dev \
		.
