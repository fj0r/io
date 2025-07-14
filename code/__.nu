export def 'build code-server' [] {
    let base = 'localhost/io:root'
    let target = 'http://file.s/code-server.tar.zst'
    let proxy = 'http://172.178.1.111:7890'
    let proxy = $"\nENV http_proxy=($proxy)\nENV https_proxy=($proxy)"
    mut args = []
    $args ++= ["--build-arg" $"BASEIMAGE=($base)"]
    let $dockerfile = open -r Dockerfile
    | str replace -mr '^(FROM \$\{BASEIMAGE\})$' $"$1 AS build($proxy)"
    $"_: |-

    FROM ${BASEIMAGE}
    COPY --from=build /opt/code-server /opt/code-server
    COPY code.sh /opt/code-server
    RUN set -eux \\
      ; cd /opt \\
      #; tree -L 3 \\
      ; tar cf - code-server \\
      | zstd -18 -T0 \\
      | curl -L -T - ($target)
    "
    | from yaml | get _
    | $"($dockerfile)\n\n($in)"
    | ^$env.CNTRCTL build ...$args -f - -t temp .
}
