---
title: TLV格式 及 VARINT数值压缩存储方法
date: 2017-03-05 03:07:57
tags: 技术随笔
---
*迁移的之前的文章*

最近需要使用Thrift格式进行数据序列化反序列化，遇到一些问题，所以看了下thrift的java库以及python库，学习了下thrift的存储格式，主要使用thrift的TCompactProtocol。
发现该序列化方式主要使用了TLV格式式来存储每个字段，使用VARINT来表示其中的L。

## TLV 格式
很简单，**Type-length-value**（类型-长度-值）。在一串字节中，使用该方式标示出一个自定义的字段。
三个域的表示方式均可自定义。如使用1个字节标示数据类型T，使用4个字节标示数据长度L，之后使用L个字节来表示数据的值。（其实Thrift的TBinaryProtocol就是这种方式）

## VARINT 数值压缩存储
c中int使用4个固定字节表式，即使数字很小。假如使用int16，则不能表示较大的数字。
而VARINT是一种可变长度的表示数字的方法，当数字较小时可以使用1个字节，如果比较大需要利用5个。
int转为varint，TCompact 的java实现如下：
```Java
private void writeVarint32(int n) {                                 int idx = 0;
    while (true) {
        if ((n & ~0x7F) == 0) {
            i32buf[idx++] = (byte)n;
            break;
        } else {
            i32buf[idx++] = (byte)((n & 0x7F) | 0x80);
            n >>>= 7;
        }
    }
    trans_.write(i32buf, 0, idx); // trans_不用管，可以看作字节流
  }  
```

其实就是，依次从字节串的末尾选取7位，最高位添加1或0构造出1个字节。并且，只有最后一次选取时最高位置为0，此时剩余的位构成到数字是小于 1000 0000，的所以添加0并不会影响其大小。如下：
```
10进制: 296
16进制: x01 x28
 2进制: 0000 0001 0010 1000
      a            --- ----  ==> 1010 1000  选择末7位，最高位置为1
      b    -- ---- -         ==> 1010 1000 0000 0010  右移7位，选择末7位，最高位置为0
VARINT: 1010 1000 0000 0010
16进制：xa8 x02
```

很明显，通过这种方法，我们得到的VARINT，依次读取每个字节，只有表示该VARINT的最后一个字节，最高位为0。所以，当我们读取VARINT时，只要读取到最高位为0的字节时，就表示已经是VARINT的最后一个字节了。

结合TLV就是：先读取1个字节得到类型T；然后读取n个字节计算出长度L，其中第n个字节的最高位为0；然后读取L个字节，表示我们的V。

最后，我们看下读取VARINT时，python的处理方法：
```Python
def readVarint(trans):
    result = 0 
    shift = 0 
    while True:
        x = trans.readAll(1)    // 读取下一个字符
        byte = ord(x)              // 转成整数表示
        result |= (byte & 0x7f) << shift // 将该字节去掉最高位放在已有结果的左侧
    if byte >> 7 == 0:       // 如果该字节最高位是0，结束
        return result
    shift += 7
```

