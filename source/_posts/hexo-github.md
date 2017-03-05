---
title: 搭建个人博客：Github、Hexo
date: 2017-03-05 03:20:15
tags: 技术随笔
---

去年使用搬瓦工的VPS，使用*Ghost*搭建的博客，前几天忘记续费，又赶上Vultr做活动，所以更换为Vultr的VPS了。
Vultr搭建了Shadosocks，速度杠杠的，通过这个链接购买有优惠哦：[Vultr优惠通道](http://www.vultr.com/?ref=7123589)

想在新环境下搭一套*Ghost*博客，可是总有问题，*Ghost*开始商业化后也对源码不怎么样上心。自己从头搭建博客，网站内容也需要自己想办法备份，在搬瓦工上就是忘记备份了 ┑(￣Д ￣)┍。
想要尝试下**Hexo + Github**，不用准备服务器，也不用考虑备份，就是需要本地生成再push到github，没有直接在网站后台编辑文章方便。 

## 快速概览
**Github Pages**是Github提供的，用于展示用户/项目，特定仓库放的静态网页可以直接通过域名访问到，就像访问网站似的。它的官方好基友是[Jekyll](https://jekyllrb.com/)，Ruby实现，用于转换*Markdown*为静态网页。
**Hexo**是另一个使用广泛的静态网页生成框架，由Node.js实现，使用更简单。
**NexT**是Hexo的一个主题，简单大气，配置方便，并且集成了一些插件，很强大。

有能力的同学可以直接看官方文档，更加清晰、直观、全面：
[空间 Github Pages](https://pages.github.com/)
[框架 Hexo](https://hexo.io/zh-cn/)
[主题 NexT](http://theme-next.iissnan.com/)

## 简单搭建
从零开始简单使用的教程，网上有很多可参考：[20分钟教你使用hexo搭建github博客](http://www.jianshu.com/p/e99ed60390a8)
在下面记录稍微高级点的用法，主要包括：独立域名、自动备份、跨机使用、自定义主题

## 备份与跨机使用
通过上一步，我们已经可以通过`hexo new xxx; vi xxx.md; hexo g -d`这简单几步来写文章并发布了。
但如何在另一台机器上写文章？在公司写了一半回家接着写怎么办？

首先了解下Hexo在github发布文章的机制：
1. github提供仓库xxx.github.io，并且使得我们可以通过域名xxx.github.io来访问该仓库的master分支下的内容
2. 在本地搭建Hexo，使用`Hexo init`构建所需的组织结构，通过`hexo new xxx`在*source/_posts*文件夹下生成文件*xxx.md*，然后手动编辑该文件写作。
3. `hexo generat`会使用*source*目录下所有内容生成静态网页，并置于*public*目录下
4. `hexo deploy`时，会将public种的内容在*.depoly_git*目录add并commit，然后*git push -f*到仓库的master分支上，注意是强制push。

上述过程可以看到，目前发布的内容是依赖于本机的配置以及source目录中的内容生成的。如果切换到新机器，没有hexo可以重装，没有相应配置可以再配一次（虽然比较麻烦），可是没有source目录执行`hexo g -d`时就会将原有网页清掉，完全变成新机器上所生产的内容了。
我们希望 **可以方便地在新机器获得与原有机器相同的使用环境**。其实很简单，将用到的配置、源文件自动备份就可以了。
Hexo会自动生成网页并push到相应master分支，我们手动将与生成网页相关的文件备份。Git方便备份也方便还原，所以可选择Oschina等私有仓库，也可选择Github等公开仓库，还可使用同一仓库的不同分支。
这里我们使用Github仓库xxx.github.io的hexo分支：
1. 仓库xxx.github.io新建hexo分支，并将其设置为默认分支
2. `git clone https://github.com/xxx/xxx.github.io.git` 到本地xxx目录
3. 本机`hexo init project`，并将project中内容复制到xxx中。（！不可直接在xxx中执行`hexo init`，这个命令会将原有.git文件夹清空）
4. 大力配置一番，并将无用文件加入.gitignore，`git add -all; git commit; git push`

我的.gitignore文件为：
```
db.json
debug.log
node_modules/
public/
.deploy_git/
```

之后再写文章，改配置，换主题等，按如下步骤：
```Shell
# 新增文章或做更改
hexo new "post name"
# 源文件push到hexo分支
git add .
git commit -m 'message'
git push
# 生成网页并部署
hexo generate
hexo deploy
```
在另一台新机器上使用时
```Shell
# GIT_URL 是仓库地址，PROJECT是在本机的目录
git clone $GIT_URL $PROJECT
cd $PROJECT
# ①
npm install hexo
npm install
```
在另一台机器上继续写文章时
```Shell
git pull   # !!! 不要忘记 !!!
# ①
```

还记得之前说过`hexo deploy`使用的命令类似`git push -f`吗？如果想保留之前的发布记录，即master分支历史，在①处执行操作`git clone $GIT_URL --branch master --single-branch .deploy_git`。不执行会按照当前记录强制push，更改github上的commit 历史，当然这点对我们部署的网站没有太大影响，我们最终要看的是展现出来的网站，并且源文件的历史记录在hexo分支上也有。

## 独立域名
独立域名是指使用自己申请的域名，[yulianfei.cn](http://yulianfei.cn)这种；而不是分配的*xxx.github.io*这种。
1. 向域名服务商申请独立域名xxx.com；服务商有万网、Godaddy等
2. 在仓库xxx.github.io的setting中，在*Custom domain*中填入申请到的*xxx.com*
3. 在Hexo的source文件夹下新建文件，文件名为CNAME，内容为xxx.com，然后通过hexo g -d 生成并部署
4. 在域名服务商出设置DNS解析，添加A纪录，指向IP *192.30.252.153*、*192.30.252.154*，若有变动可查看[Github Pages Custome domain](https://help.github.com/articles/setting-up-an-apex-domain/)
5. 等待解析生效，不同服务商生效时间不同，5分钟到24小时都有可能，生效后直接输入xxx.com就可以看到自己的博客了。

## 自定义主题
太累了，不想写了，**NexT**配置起来很简单，文档看起来也很方便。
这个主题还集成了 **多说评论**、**访问统计**等，打开这两个功能，一个博客的基本功能就都有了。