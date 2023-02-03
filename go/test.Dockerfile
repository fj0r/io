FROM io:latest

RUN set -eux \
  ; cd \
  ; printf "package main\n\nimport \"fmt\"\n\nimport \"rsc.io/quote\"\n\nfunc main() {\n    fmt.Println(quote.Go())\n}\n" > hello.go \
  ;
