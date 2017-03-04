## 提交
```
# 新增文章
hexo new "post name"

# 源文件push到hexo分支
git add .
git commit -m 'message'
git push

# 生成网页并部署，其实是将生成的public内容push到master分支
hexo generate
hexo deploy
```

## 在另一台机器上重新搭建
```
git clone $GIT_URL $PROJECT  # GIT_URL 是本项目地址
cd $PROJECT
# 如果想保留之前的文章发布记录，即master分支历史
git clone $GIT_URL --branch master --single-branch .deploy_git
npm install hexo
npm install
```

## 在另一台机器上继续使用
```
git pull   # !!! 不要忘记 !!!
```
