# `not-used` directory

In this directory I wanted to document the steps I've followed to add an  [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/) to the nextcloud deployment.
I was not able to catch what was missing to make it work in a reasonable time, for this reason this file are not in the main directory of the presented solution. 

### 1. Install the `nginx` ingress controller

Following the official nextcloud documentation's recommendation, I've chosen to use the [nginx ingress controller](https://kubernetes.github.io/ingress-nginx/deploy/).
I've installed it with the following commands:

```bash
cd ./ingress-nginx
kubectl apply -f ingress-nginx-controller.yaml
kubectl wait --for=condition=available --timeout=600s deployment/ingress-nginx-controller -n ingress-nginx
```

### 2. Update the `values.yaml` file

I've enabled the `ingress` in the `values.yaml` and added the suggested annotations:

```yaml
ingress:
  enabled: true
  annotations:
    nginx.ingress.kubernetes.io/cors-allow-headers: "X-Forwarded-For"
    nginx.ingress.kubernetes.io/proxy-body-size: 4G
    kubernetes.io/tls-acme: "true"
    cert-manager.io/issuer: "selfsigned"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/enable-cors: "true"
    nginx.ingress.kubernetes.io/server-snippet: |-
       server_tokens off;
       proxy_hide_header X-Powered-By;

       rewrite ^/.well-known/webfinger /public.php?service=webfinger last;
       rewrite ^/.well-known/host-meta /public.php?service=host-meta last;
       rewrite ^/.well-known/host-meta.json /public.php?service=host-meta-json;
       location = /.well-known/carddav {
         return 301 $scheme://$host/remote.php/dav;
       }
       location = /.well-known/caldav {
         return 301 $scheme://$host/remote.php/dav;
       }
       location = /robots.txt {
         allow all;
         log_not_found off;
         access_log off;
       }
       location ~ ^/(?:build|tests|config|lib|3rdparty|templates|data)/ {
         deny all;
       }
       location ~ ^/(?:autotest|occ|issue|indie|db_|console) {
         deny all;
       }
  className: nginx
  path: / 
  hosts:
    - nextcloud.example.com
  servicePort: https
  tls:
    - secretName: nextcloud-tls
      hosts:
        - nextcloud.example.com
```  


Where the `tls` section is used to specify the secret name and the hosts for the certificate. To install the [`cert-manager`](https://github.com/cert-manager/cert-manager?tab=readme-ov-file) and its `kubectl` plugin:

```
kubectl create namespace cert-manager
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.7.1/cert-manager.yaml

curl -L -o kubectl-cert-manager.tar.gz https://github.com/jetstack/cert-manager/releases/latest/download/kubectl-cert_manager-linux-amd64.tar.gz
tar xzf kubectl-cert-manager.tar.gz
sudo mv kubectl-cert_manager /usr/local/bin
```
And to create the self-signed certificate:

```
kubectl apply -f certificate.yaml -n nextcloud
```
