#!/bin/sh
sed -i s/"Go Web App"/"Tanzu Go Web App"/g $HOME/gowebapp/gowebapp/code/template/index/auth.tmpl
sed -i s/"Go Web App"/"Tanzu Go Web App"/g $HOME/gowebapp/gowebapp/code/template/base.tmpl

docker build -t gowebapp:v1.1 $HOME/gowebapp/gowebapp
docker tag gowebapp:v1.1 sa-master-01.vclass.local:443/gowebapp:v1.1
docker push sa-master-01.vclass.local:443/gowebapp:v1.1


