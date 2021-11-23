FROM fj0rd/io

ENV GOROOT=/opt/go GOPATH=${HOME:-/root}/go
ENV PATH=${GOPATH}/bin:${GOROOT}/bin:$PATH
ENV GO111MODULE=on
RUN set -eux \
  ; cd /opt \
  ; GO_VERSION=$(xh -F https://golang.org/VERSION m==text) \
  ; xh -F https://dl.google.com/go/${GO_VERSION}.linux-amd64.tar.gz | tar xzf - \
  ; go get -u -v \
      go.uber.org/zap \
      github.com/juju/errors \
      github.com/spf13/viper \
      github.com/spf13/cobra \
      github.com/gin-gonic/gin \
      github.com/jinzhu/gorm \
      honnef.co/go/tools/... \
      2>&1 \
  ; go install golang.org/x/tools/gopls@latest \
  ; go install github.com/go-delve/delve/cmd/dlv@latest \
  ; rm -rf $(go env GOCACHE)/* \
  ; find ${HOME}/go/bin -type f -links 1 -exec grep -IL . "{}" \; | xargs -L 1 strip -s \
  ; go env -w GOPROXY=https://goproxy.cn,direct
