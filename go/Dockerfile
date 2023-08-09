FROM fj0rd/io:latest

ENV GOROOT=/opt/golang GOPATH=/opt/go
ENV PATH=${GOPATH}/bin:${GOROOT}/bin:$PATH
ENV GO111MODULE=on
RUN set -eux \
  ; mkdir -p $GOROOT $GOPATH \
  ; GO_VERSION=$(curl --retry 3 -sSL 'https://go.dev/VERSION?m=text' | head -n 1) \
  ; curl --retry 3 -sSL https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz | tar xzf - -C ${GOROOT} --strip-components=1 \
  #; go get -u -v \
  ; go mod download \
      github.com/sirupsen/logrus@latest \
      github.com/spf13/viper@latest \
      github.com/spf13/cobra@latest \
      github.com/labstack/echo/v4@latest \
      github.com/jinzhu/gorm@latest \
      github.com/jackc/pgx/v4@latest \
      2>&1 \
  ; go install golang.org/x/tools/gopls@latest \
  ; go install github.com/go-delve/delve/cmd/dlv@latest \
  ; rm -rf $(go env GOCACHE)/* \
  ; find ${GOPATH}/bin -type f -exec grep -IL . "{}" \; | xargs -L 1 strip -s \
  ; opwd=$PWD; cd /world \
  ; PROJ=hello-go \
  ; mkdir $PROJ \
  ; cd $PROJ \
  ; go mod init $PROJ \
  ; printf "package main\n\nimport \"fmt\"\n\nimport \"rsc.io/quote\"\n\nfunc main() {\n    fmt.Println(quote.Go())\n}\n" > hello.go \
  ; go mod tidy \
  #; go run . \
  ; cd $opwd \
  ; go env -w GOPROXY=https://goproxy.cn,direct
