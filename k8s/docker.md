# docker

## 1 docker login 报错

1. 现象：

```shell
# docker login https://hub.docker.com/
Username: tianyu29792569
Password: 
Error response from daemon: login attempt to https://hub.docker.com/v2/ failed with status: 404 Not Found
```

2. 解决方法

这个问题并不是http://hub docker.com的网站问题，因为用电脑浏览器登陆是可以等上去的，而是网址不对的问题，正确的语法应该是
docker login [index.docker.io](http://index.docker.io/)

```shell
# docker login index.docker.io
Username: tianyu29792569
Password: 
WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded

# vim ~/.docker/config.json 

{
        "auths": {
                "index.docker.io": {
                        "auth": "dGlhbnl1Mjk3OTI1Njk6QWIuMTIzNDU="
                }
        },
        "HttpHeaders": {
                "User-Agent": "Docker-Client/19.03.9 (linux)"
        }
}
```

```shell
# 登录
# docker login
Login with your Docker ID to push and pull images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one.
Username: tianyu29792569
Password: 
WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded

# docker tag tomcat-base docker.io/tianyu29792569/tomcat-base
# docker push tianyu29792569/tomcat-base
```





