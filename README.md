# Nginx reverse proxy for Django Application

This project features how to containerize a Django application with Nginx reverse proxy and run that in Kubernetes cluster.

## Theory

Any Django application runs on a WSGI(A Web Server Gateway Interface) server. Gunicorn is a popular WSGI application server usually used to run Django applications in production. In order to use Nginx for security purposes, nginx proxy server setup is needed which redirects all incoming traffic to Gunicorn application server and mask the real ip address.

## Setup

To get this repository, run the following command inside your git enabled terminal

```bash
git clone https://github.com/SouvikGhosh05/django-todo.git
```

Pull the docker container on your machine to test the app. For this command to work, you must have docker installed on your machine.

```bash
docker pull souvikdocks250/todoapp:v1
```

Once you have downloaded django, go to the cloned repo directory and run the following command

Every nginx application have its default configuration saved in *default.conf* file. The file should look like this:-

```conf
upstream django_project {
    server localhost:8000;
}

error_log /var/log/nginx/error.log;

server {
    listen       80;
    server_name  <kubernetes-node-ip> localhost;
    root   /www/data/;
    access_log /var/log/nginx/access.log;

    location / {
        proxy_pass http://django_project;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $host;
        proxy_redirect off;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
```

If you use NodePort service you should put kubernetes node ip in `<kubernetes-node-ip>` block. If you run minikube, you will get the node ip by running `minikube ip` command.
This configuration was passed via using configmap with `configmap.yaml` here.

In this project I have created a deployment with 3 replicas and used NodePort service to access the appliation from your machine. Run the following commands to deploy it:-

```bash
chmod +x kubernetes-deploy.sh
./kubernetes-deploy.sh
```

In the following, you will see the `django-todo-app-service` is running on 32260.

```text
NAME                      TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)          AGE
django-todo-app-service   NodePort    10.99.200.208   <none>        8080:32260/TCP   2m24s
kubernetes                ClusterIP   10.96.0.1       <none>        443/TCP          347d
```

When typed `http://192.168.49.2:32260` in the browser, the app is accessible as below:-
![run with nodeport](https://raw.githubusercontent.com/SouvikGhosh05/django-todo/develop/images/nodeport.png)

It is also possible to run this app with ClusterIP service. To do that, we need to do *port-forward* method to access the app to the localhost. If you want to access the access the app to port 9090 on localhost, use the following command:-

```bash
kubectl port-forward svc/django-todo-app-service 9090:8080
```

When typed `http://localhost:9090` in the browser, the app is accessible as below:-
![run with nodeport](https://raw.githubusercontent.com/SouvikGhosh05/django-todo/develop/images/localhost.png)

Happy Kubernetes!
