#给镜像打标签  <br/>
$  docker tag image-name1:tag1  10.254.0.50:5000/image-name2:tag2  <br/>

#push镜像  <br/>
$  docker push 10.254.0.50:5000/image-name2:tag2  <br/>

#查看仓库中的镜像名  <br/>
$  curl 10.254.0.50:5000/v2/_catalog  <br/>

#查看指定镜像的tag  <br/>
$  curl 10.254.0.50:5000/v2/[image-name]/tags/list  <br/>

默认没有用户名和密码
