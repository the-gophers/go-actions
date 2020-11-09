mkdir -p bin/

echo "GOOS=linux GOARCH=amd64 go build"
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o bin/hello-gopher .
