#给镜像打标签
docker tag image-name1:tag1  10.254.0.50:5000/image-name2:tag2

#push
docker push 10.254.0.50:5000/image-name2:tag2

#查看仓库中的镜像名
curl 10.254.0.50:5000/v2/_catalog

#查看指定镜像的tag
curl 10.254.0.50:5000/v2/[image-name]/tags/list

默认没有用户名和密码
