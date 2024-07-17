# docker-environment
Docker image that shows enrironment via http and files.

## Build image

For a local image:

```shell
docker build -t nginx-envprint .
```

If you want to run this image in AKS, specify platform

```shell
docker build -t nginx-envprint-x64 --platform linux/amd64 .
```

## Push image

```
docker tag nginx-envprint myregistry.azurecr.io/nginx-envprint
docker push myregistry.azurecr.io/nginx-envprint
```

## Rum image locally

```shell
$ docker run -d -p 8080:80 nginx-envprint
```

or

```shell
$ docker compose up -d
```

Access environment with `curl`:

```
$ curl http://localhost:8080/env.txt
HOSTNAME=2bff26821580
SHLVL=2
HOME=/root
PKG_RELEASE=2
NGINX_VERSION=1.27.0
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
NJS_VERSION=0.8.4
NJS_RELEASE=2
PWD=/
```

## Run image in k8s cluster

Use appropriate docker commands for the k8s cluster.

## Use running image

Once the image is initialized, access

http://host:80/env.txt

and 

http://host:80/log.txt

The environment and log are in:

/usr/share/nginx/html/env.txt
and
/usr/share/nginx/html/log.txt
