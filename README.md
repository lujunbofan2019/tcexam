### 1.安装docker及docker-compose
#### 1.1卸载旧版本
```
$ sudo yum remove docker \
                  docker-common \
                  docker-selinux \
                  docker-engine
```
#### 1.2安装所需的软件包
```
$ sudo yum install -y yum-utils device-mapper-persistent-data lvm2
```
#### 1.3设置stable镜像仓库
```
$ sudo yum-config-manager \
       --add-repo \
       https://download.docker.com/linux/centos/docker-ce.repo
```
#### 1.4更新软件包索引
```
$ sudo yum makecache fast
```
#### 1.5安装最新版本的 Docker CE
```
$ sudo yum install docker-ce
```
#### 1.6设置国内镜像源并修改镜像默认保存地址
修改 /etc/docker/daemon.json 文件并添加上 registry-mirrors 键值。  
因为我们一般都使用云服务器，所以把docker数据默认保存位置修改到较大的数据云盘上（在此之前记得数据云盘初始化）。
```
{
  "registry-mirrors": ["https://registry.docker-cn.com"],"graph": "/data/docker"
}
```
修改保存后重启 Docker 以使配置生效。  
```
$ sudo systemctl restart docker
```
#### 1.6.1 设置定时清除docker日志
docker什么都很好，就是太占用存储空间，日志需要定期清理。
```
mkdir -p /data/shell
cd /data
vi shell/clean_docker_log.sh
```
shell内容如下：
```
#!/bin/sh 

echo "======== start clean docker containers logs ========"  
#logs=$(find /var/lib/docker/containers/ -name *-json.log)
logs=$(find /data/docker/containers/ -name *-json.log)  

for log in $logs  
        do  
                echo "clean logs : $log"  
                cat /dev/null > $log  
        done  

echo "======== end clean docker containers logs ========"  

docker rm `docker ps -a | grep Exited | awk '{print $1}'` 
docker rmi -f  `docker images | grep '<none>' | awk '{print $3}'`  
```
设置shell可执行，并添加crontab任务
```
chmod 755 shell/clean_docker_log.sh
crontab -e
```
添加crontab任务
```
30 0 * * 0 /data/shell/clean_docker_log.sh
```
#### 1.7安装docker-compose

```
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```
#### 1.6.2 设置docker应用为服务
```
systemctl enable docker.service
```
### 2.配置tcexam
#### 2.0.1 下载文件到/home/git
```
git clone https://gitee.com/39627020/tcexam_docker.git
```
#### 2.0.2 启动tcexam容器
```
cd /home/git/tcexam_docker
docker-compose up -d --build
```
#### 2.1 进入docker容器，修改mysql root密码
```
docker exec -it tcexam /bin/bash
mysqladmin --user=root password "newpass"
```
#### 2.2 修改目录权限
```
cd /home/git/tcexam/
chmod -R 777 install
chmod -R 777 shared
```
#### 2.3 生成默认配置文件
```
cd /home/git/tcexam/admin
cp -R config.default/ config
cd /home/git/tcexam/shared
cp -R config.default/ config
cd /home/git/tcexam/public
cp -R config.default/ config
```
#### 2.4 修改时区(通过拷贝修改后的php.ini文件到容器实现)
```
cd /home/git/tcexam
docker cp ./php.ini tcexam:/opt/lampp/etc/
```
#### 访问安装页面
```
http://ip:5000/install/install.php
```
### 如果安装步骤都是OK就安装成功了，登录账号密码如下：
```
user:admin
pass:1234
```
### 最后添加了简单了使用手册可以使用
