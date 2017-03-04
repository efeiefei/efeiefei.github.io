---
title: Google S2，球面几何，希尔伯特曲线
date: 2017-03-05 03:09:17
tags: [GEO,翻译]
---

*迁移的老的文章*

--

翻译自 [Google’s S2, geometry on the sphere, cells and Hilbert curve](http://blog.christianperone.com/2015/08/googles-s2-geometry-on-the-sphere-cells-and-hilbert-curve/)


--


[Google S2 库](https://code.google.com/archive/p/s2-geometry-library/)是个珍宝，不仅因为它在空间索引方面的优秀表现，也因为它已经诞生4年多却没有受到应有的重视。S2库被用在Google Map、MongoDB、Foursquare上；但除了Foursquare的一篇论文、[Google的幻灯片](https://docs.google.com/presentation/d/1Hl4KapfAENAOf4gv-pSngKwvS_jwNVHRPZTTDzXXn6Q/view#slide=id.i0)以及源代码的注释，你不能找到任何相关文章或文档。你也许在努力的寻找S2的bingding，但官方代码库已经丢失了Python库的Swig文件，感谢[一些fork](https://github.com/micolous/s2-geometry-library)使我们还能获取Python的一部分binging。据说最近Google正积极的对S2进行开发，也许不久我们就能获得这个库更详细的信息，但我决定分享一些使用该库的样例，还有该库这么酷的原因。


## 了解cell
你会在整个S2代码里面看到`cell`的概念。Cell是球面（对我们来说是地球，但不局限于此）层次分解之后对region和point的紧凑的表示。Region也可以使用同样的Cell近似表示，这种Cell有不少优秀的属性：


* 特别紧凑（由64-bit整数表示）
* 具有地理特性上的解决方案（译者注：resolution for geographical features）
* 分层的（具有不同level，相似level含有相似的范围）
* 对任意region的包含查询非常快


首先，S2将球面上的point/region投影到立方体上，立方体的每个面都有一棵四叉树，球面上的点就投影在这棵四叉树上。然后，进行一些转换（详细原因查看[Google的幻灯片](https://docs.google.com/presentation/d/1Hl4KapfAENAOf4gv-pSngKwvS_jwNVHRPZTTDzXXn6Q/view#slide=id.i22)）将空间离散。接着，Cell被映射在[希尔伯特曲线](https://en.wikipedia.org/wiki/Hilbert_curve)上，这也是S2如此优秀的原因。希尔伯特曲线是一种空间填充曲线，它将多维转为一维，并拥有特殊的空间特征：含有局域性信息。


## 希尔伯特曲线
![hilbert_curve](http://7xrcvy.com1.z0.glb.clouddn.com/efei-ghost-Hilbert_curve.gif)


希尔伯特曲线是空间填充曲线，它覆盖了整个n-维空间。为了理解它的工作原理，你可以想象一条长长的绳子被以特殊的方式放置在空间中，使得这条绳子经过空间中的每个方形区域，从而填满了整个空间。为了将2D point映射在希尔伯特曲线上，你只需要选取该point所在位置的那条长长的绳子上的点就可以了。为了更容易理解希尔伯特曲线，你可以使用[这个交互式样例](http://bit-player.org/extras/hilbert/hilbert-mapping.html)，点击曲线上任意一点将会显示在绳子上这个点的位置，反之亦然。


在下面这幅图中，希尔伯特曲线最开始的点也位于图片下方绳子的最开始位置。
![hilbert_begin](http://7xrcvy.com1.z0.glb.clouddn.com/efei-ghost-hilbert_begin.png)


下面这幅图含有很多的点，很容易可以看到希尔伯特曲线是如何表示空间位置的。可以看到，曲线（一维表示，最下方的线）上离得越近的点同样在2D空间（x,y平面）离得越近。然而，也可以看到，反过来并不一定正确，在x,y平面上相近的2D point在希尔伯特曲线上却不一定相近。
![hilber_middel](http://7xrcvy.com1.z0.glb.clouddn.com/efe-ghost-hilbert_middle.png)


S2使用希尔伯特曲线来枚举cell，意味着cell value相近的在空间上也相近。这种思想与层次分解相结合，便得到了索引与查询速度都非常快的框架。在开始具体示例之前，我们看一下cell是如何使用64-bit整数来表示的。


*如果对希尔伯特曲线感兴趣，[这篇文章](http://datagenetics.com/blog/march22013/index.html)直观的展现了该曲线的属性。*


## cell的表示
就像我已经提到的，cell具有不同的level，可以覆盖不同的region。在S2库中含有层次分解的30个level。Google幻灯片中展示了各种cell level以及他们可以覆盖的范围，如下图：
![s2_cell_area](http://7xrcvy.com1.z0.glb.clouddn.com/efei-ghost-s2_cell_area.png)


可以看到，S2一个非常酷的特点是地球上每cm<sup>2</sup>都可以用64-bit整数来表示。


cell使用如下模式来表示：
![cell_representation](http://7xrcvy.com1.z0.glb.clouddn.com/efei-ghost-cells_representation.png)


第一个表示一个叶子cell，叶子cell表示最小的区域，通常用来表示point。正如你看到的，初始的3个bit被保留下来存储球面投影到立方体的面，紧跟着的是希尔伯特曲线上cell的位置，然后是一个为`1`的bit，用以识别cell的level。


所以，检查cell的level，需要做的就是检查cell表示中最后一个`1`bit出现的位置。包含关系的检查，验证一个cell是否在另一个cell中，需要做的仅仅是一个前缀对比。这些操作非常快，也只有希尔伯特曲线及层次分解方法的使用才能将其变为可能。


## 覆盖region
如果想要产生一些cell来覆盖一个region，你可以使用库里的一个方法，传入cell的最大数量、cell的最大level、cell的最小level这些参数。下面的例子中，我使用S2库来**提取一些机器学习的二进制特征**，指定level为15：
![cell_15_level](http://7xrcvy.com1.z0.glb.clouddn.com/efei-ghost-cell_15_level.png)
上面图片中使用透明的多边形覆盖了我所在城市感兴趣的整个区域，那些就是cell股改的区域。我在最大level及最小level都是使用的15，所以每个cell都覆盖了相似的区域大小。如果我将最小level设为8（使其可以使用更大的cell），S2库将会使用更少的cell，并保持近似的精度，如下：
![cell_15_8](http://7xrcvy.com1.z0.glb.clouddn.com/efei-ghost-level_15_8.png)
可以看到，现在我们在中央使用更大的cell，在周边使用小一些的cell以保持精度。


##示例
** In this tutorial I used the Python 2.7 bindings from the following repository. The instructions to compile and install it are present in the readme of the repository so I won’t repeat it here.*
The first step to convert Latitude/Longitude points to the cell representation are shown below:
```Python
>>> import s2
>>> latlng = s2.S2LatLng.FromDegrees(-30.043800, -51.140220)
>>> cell = s2.S2CellId.FromLatLng(latlng)
>>> cell.level()
30
>>> cell.id()
10743750136202470315
>>> cell.ToToken()
951977d377e723ab
```
As you can see, we first create an object of the class **S2LatLng** to represent the lat/lng point and then we feed it into the **S2CellId** class to build the cell representation. After that, we can get the level and id of the class. There is also a method called **ToToken** that converts the integer representation to a compact alphanumerical representation that you can parse it later using **FromToken** method.


You can also get the parent cell of that cell (one level above it) and use containment methods to check if a cell is contained by another cell:


```Python
>>> parent = cell.parent()
>>> print parent.level()
29
>>> parent.id()
10743750136202470316
>>> parent.ToToken()
951977d377e723ac
>>> cell.contains(parent)
False
>>> parent.contains(cell)
True
```
As you can see, the level of the parent is one above the children cell (in our case, a leaf cell). The ids are also very similar except for the level of the cell and the containment checking is really fast (it is only checking the range of the children cells of the parent cell).


These cells can be stored on a database and they will perform quite well on a BTree index.  In order to create a collection of cells that will cover a region, you can use the **S2RegionCoverer** class like in the example below:


```Python
>>> region_rect = S2LatLngRect(
        S2LatLng.FromDegrees(-51.264871, -30.241701),
        S2LatLng.FromDegrees(-51.04618, -30.000003))
>>> coverer = S2RegionCoverer()
>>> coverer.set_min_level(8)
>>> coverer.set_max_level(15)
>>> coverer.set_max_cells(500)
>>> covering = coverer.GetCovering(region_rect)
```
First of all, we defined a **S2LatLngRect** which is a rectangle delimiting the region that we want to cover. There are also other classes that you can use (to build polygons for instance), the **S2RegionCoverer** works with classes that uses the **S2Region** class as base class. After defining the rectangle, we instantiate the **S2RegionCoverer** and then set the aforementioned min/max levels and the max number of the cells that we want the approximation to generate.


If you wish to plot the covering, you can use Cartopy, Shapely and matplotlib, like in the example below:


```Python
import matplotlib.pyplot as plt
from s2 import *
from shapely.geometry import Polygon
import cartopy.crs as ccrs
import cartopy.io.img_tiles as cimgt
proj = cimgt.MapQuestOSM()
plt.figure(figsize=(20,20), dpi=200)
ax = plt.axes(projection=proj.crs)
ax.add_image(proj, 12)
ax.set_extent([-51.411886, -50.922470,
               -30.301314, -29.94364])
region_rect = S2LatLngRect(
    S2LatLng.FromDegrees(-51.264871, -30.241701),
    S2LatLng.FromDegrees(-51.04618, -30.000003))
coverer = S2RegionCoverer()
coverer.set_min_level(8)
coverer.set_max_level(15)
coverer.set_max_cells(500)
covering = coverer.GetCovering(region_rect)
geoms = []
for cellid in covering:
    new_cell = S2Cell(cellid)
    vertices = []
    for i in xrange(0, 4):
        vertex = new_cell.GetVertex(i)
        latlng = S2LatLng(vertex)
        vertices.append((latlng.lat().degrees(),
                         latlng.lng().degrees()))
    geo = Polygon(vertices)
    geoms.append(geo)
print "Total Geometries: {}".format(len(geoms))
    
ax.add_geometries(geoms, ccrs.PlateCarree(), facecolor='coral',
                  edgecolor='black', alpha=0.4)
plt.show()
```
And the result will be the one below:
![covering_ipython](http://7xrcvy.com1.z0.glb.clouddn.com/efei-ghost-covering_ipython.png)


There are a lot of stuff in the S2 API, and I really recommend you to explore and read the source-code, it is really helpful. The S2 cells can be used for indexing and in key-value databases, it can be used on B Trees with really good efficiency and also even for Machine Learning purposes (which is my case), anyway, it is a very useful tool that you should keep in your toolbox. I hope you enjoyed this little tutorial !


– Christian S. Perone