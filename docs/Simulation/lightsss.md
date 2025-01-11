# lightSSS 使用说明

lightSSS由香山的lightSSS移植,详细原理请开原文档：https://docs.xiangshan.cc/zh-cn/latest/tools/lightsss/

旨在尽可能降低仿真波形带来的开销，同时尽可能保留波形信息，提升debuger效率。

## lightSSS区别
**仅支持verilator版本大于5.016请将版本更新至5.016以上**

**与原先chiplab相比，std=c++11更改为std=c++14**

**移植香山lightSSS代码，其他功能与原版chiplab功能一致**

## 使用方法

打开sims/verilator/run_prog/Makefile_run文件

修改FORK_CHILD=1 即为开启lightSSS功能（不需要开启DUMP_WAVEFORM）
```
DUMP_WAVEFORM=0
FORK_CHILD=1
```

依照正常使用chiplab方法运行。

即可看到fork_simu_trace.{fst,vcd}文件的生成

注：**由于lightSSS依赖子进程运行两次，因此log重复生成属于正常现象**

## 参数说明
| 参数名称        | 参数描述                                         |
| :-------------- | :---------------------------------------------  |
| `FORK_INTERVAL` | 每多长时间（ms）fork一个子进程                    |
| `SLOT_SIZE`     | 同时最多支持多少个子进程存在，多余的会被kill掉      |
| `WAIT_INTERVAL` | 子进程每隔多长时间（seconds）检查父进程的信号       |
## 测试
仅在Openla500上测试lightSSS功能，且运行时间有显著下降，预计大型规模波形测试上可以带来10倍左右的性能提升。

