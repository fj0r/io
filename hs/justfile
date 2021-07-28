b:
    docker build . -t hs -f Dockerfile-local \
        --build-arg http_proxy=${http_proxy} \
        --build-arg https_proxy=${https_proxy}

bud:
    buildah bud -t hs .

build:
    docker run --name build-hs \
        -it \
        --rm \
        -v $PWD:/world \
        -e http_proxy=${http_proxy} \
        -e https_proxy=${https_proxy} \
        nnurphy/k8su \
        bash

buildk:
    docker run --name build-hs \
        -it \
        --rm \
        -v $PWD:/world \
        -e http_proxy=${http_proxy} \
        -e https_proxy=${https_proxy} \
        gcr.io/kaniko-project/executor:latest \
        --dockerfile=/world/Dockerfile \
        --context=dir://world \
        --no-push \
        --tarPath=/world/hs.tar