ARG BASEIMAGE=ghcr.io/fj0r/io:latest
FROM ${BASEIMAGE}

ENV GOROOT=/opt/golang GOPATH=/opt/go
ENV PATH=${GOPATH}/bin:${GOROOT}/bin:$PATH
ENV GO111MODULE=on
RUN set -eux \
  ; sudo mkdir -p $GOROOT $GOPATH \
  ; GO_VERSION=$(curl --retry 3 -sSL 'https://go.dev/VERSION?m=text' | head -n 1) \
  ; curl --retry 3 -sSL https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz | sudo tar xzf - -C ${GOROOT} --strip-components=1 \
  #; go get -u -v \
  ; sudo env "PATH=$PATH" go mod download \
      github.com/duke-git/lancet/v2@latest \
      github.com/sirupsen/logrus@latest \
      github.com/spf13/viper@latest \
      github.com/spf13/cobra@latest \
      github.com/labstack/echo/v4@latest \
      github.com/jinzhu/gorm@latest \
      github.com/jackc/pgx/v4@latest \
      2>&1 \
  ; sudo env "PATH=$PATH" go install golang.org/x/tools/gopls@latest \
  ; sudo env "PATH=$PATH" go install github.com/go-delve/delve/cmd/dlv@latest \
  ; sudo rm -rf $(go env GOCACHE)/* \
  ; find ${GOPATH}/bin -type f -exec grep -IL . "{}" \; | xargs -L 1 sudo strip -s \
  ; opwd=$PWD; cd ~/world \
  ; PROJ=hello-go \
  ; mkdir $PROJ \
  ; cd $PROJ \
  ; go mod init $PROJ \
  ; printf "package main\n\nimport \"fmt\"\n\nimport \"rsc.io/quote\"\n\nfunc main() {\n    fmt.Println(quote.Go())\n}\n" > hello.go \
  ; go mod tidy \
  #; go run . \
  ; cd $opwd \
  ; go env -w GOPROXY=https://goproxy.cn,direct
