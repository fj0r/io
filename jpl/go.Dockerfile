FROM fj0rd/io:jpl

### GO
ENV GOROOT=/opt/golang GOPATH=/opt/go
ENV PATH=${GOPATH}/bin:${GOROOT}/bin:$PATH
ENV GO111MODULE=on
RUN set -ex \
  ; mkdir -p $GOROOT $GOPATH \
  ; GO_VERSION=$(curl -sSL 'https://go.dev/VERSION?m=text') \
  ; curl -sSL https://go.dev/dl/${GO_VERSION}.linux-amd64.tar.gz | tar xzf - -C ${GOROOT} --strip-components=1 \
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
  ; go install github.com/gopherdata/gophernotes@latest \
  ; gophernotes_dir=${HOME}/.local/share/jupyter/kernels/gophernotes \
  ; mkdir -p $gophernotes_dir \
  ; cp "$(go env GOPATH)"/pkg/mod/github.com/gopherdata/gophernotes*/kernel/* $gophernotes_dir \
  ; chmod +w $gophernotes_dir/kernel.json \
  ; sed "s|gophernotes|$(go env GOPATH)/bin/gophernotes|" < $gophernotes_dir/kernel.json.in > $gophernotes_dir/kernel.json \
  ; rm -rf $(go env GOCACHE)/* \
  ; find ${GOROOT}/bin -type f -exec grep -IL . "{}" \; | xargs -L 1 strip -s \
  ; opwd=$PWD; cd /world \
  ; PROJ=hello-go \
  ; mkdir $PROJ \
  ; cd $PROJ \
  ; go mod init $PROJ \
  ; cd $opwd \
  ; go env -w GOPROXY=https://goproxy.cn,direct

