# Pi-TempControl

此脚本能在高温时自动关机/重启树莓派,防止温度过高(硬核降温)

## 配置相关

    max_temp:  高温触发温度()
    high_type: 高温触发策略(shutdown/reboot)(PS.只会识别shutdown,填其他的一律视为reboot~)
    dir:       日志存放目录~

## 食用方法

### 1.下载

#### (1).下载ZIP

#### (2).Git

```
git clone https://github.com/yimo6/Pi-TempControl.git
```

### 2.配置

#### 加入定时任务(示例):

    输入: crontab -e
    */15 * * * * bash /home/root/temp.sh

> 以上命令会进行每15分钟执行脚本

## 使用许可

[MIT](LICENSE) © Richard Littauer
