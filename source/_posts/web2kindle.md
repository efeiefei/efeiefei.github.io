---
title: 推送网页到Kindle
date: 2017-03-05 02:55:26
tags: 分享
---

*迁移的之前的文章*

自己做了一个微信公众号 web2kindle，用来推送网页到kindle。

**关键环节**

1. 使用Node.js搭建web服务，响应微信请求，记录用户信息、push信息等。
2. 使用python搭建后端服务，扫描记录下的push信息，抓取网页内容他，生成mobi文件，推送到指定邮箱等。
3. 使用readability提取网页主要内容。
4. 使用亚马逊提供的kindlegen生成mobi文件。

**使用方式**：

1. 关注微信公众号：web2kindle
2. 绑定邮箱，绑定+邮箱，如：绑定123@kindle.cn
3. 如果是原生kindle，需要把web2kindle@kindler.top加入到亚马逊个人中心的信任列表中；多看不需要
4. 直接输入网址，等待推送就可以了。
![](http://7xrcvy.com1.z0.glb.clouddn.com/efei-ghost-web2kindle-wxgzh.jpg)