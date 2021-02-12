#!/bin/sh

max_temp=70           #触发(高温决策)温度
high_type="reboot"    #高温决策(reboot/shutdown)
dir="./tempControl/"  #目录


mtime=$(date "+%Y/%m/%d %H:%M:%S")
nowdate=$(date "+%Y-%m-%d-%H-%M")
temp_all=`cat /sys/class/thermal/thermal_zone0/temp`
temp=`expr $temp_all / 1000`
ctemp=`expr $max_temp - $temp`
cpu_total1=`cat /proc/stat | grep "cpu " | awk '{print $2+$3+$4+$5+$6+$7}'`
cpu_used1=`cat /proc/stat | grep "cpu " | awk '{print $2+$3+$4+$7}'`
sleep 1
cpu_total2=`cat /proc/stat | grep "cpu " | awk '{print $2+$3+$4+$5+$6+$7}'`
cpu_used2=`cat /proc/stat | grep "cpu " | awk '{print $2+$3+$4+$7}'`
cpu=$((($cpu_used2-$cpu_used1)*100/($cpu_total2-$cpu_total1)))
error_file=$dir/error/$nowdate".txt"
log_file=$dir/log/$nowdate".txt"
info_file=$dir"/info.txt"
one_overload=`cat /proc/loadavg | awk '{print $1}'`
five_overload=`cat /proc/loadavg | awk '{print $2}'`
fifth_overload=`cat /proc/loadavg | awk '{print $3}'`
tmp1=`cat /proc/meminfo | awk '{print $2}' | sed -n '1p'`
tmp2=`cat /proc/meminfo | awk '{print $2}' | sed -n '3p'`
tmp3=`expr $tmp1 - $tmp2`
tmp_bfb=`expr $tmp2 \* 10`
total_mem=`expr $tmp1 / 1024`
free_mem=`expr $tmp2 / 1024`
used_mem=`expr $tmp3 / 1024`
usage_mem=`expr $tmp_bfb / $tmp1`

if [ ! -d $dir ];then
  mkdir $dir
fi

if [ ! -d $dir"/error/" ];then
  mkdir $dir"/error/"
fi

if [ ! -d $dir"/log/" ];then
  mkdir $dir"/log/"
fi

if [ $temp -gt $max_temp ];then
	echo "<${mtime}>" > $error_file
	echo "CPU利用率: "$cpu"%" >> $error_file
	echo "内存使用状态: "$used_mem"MB/"$total_mem"MB" >> $error_file
	echo "内存利用率: ${usage_mem}%" >> $error_file
	echo "一分钟内负载: ${one_overload}" >> $error_file
	echo "五分钟内负载: ${five_overload}" >> $error_file
	echo "十五分钟内负载: ${fifth_overload}" >> $error_file
	echo "温度超过${max_temp}度 (现在温度: ${temp}度)! 系统已自动执行策略("$high_type")" >> $error_file
	cp $error_file $info_file
	if [ $high_type = "shutdown" ];then
		sudo shutdown -h now
	else
		sudo shutdown -r $rebot_time
	fi
else
	echo "<${mtime}>" > $log_file
	echo "CPU利用率: "$cpu"%" >> $log_file
	echo "内存使用状态: "$used_mem"MB/"$total_mem"MB" >> $log_file
	echo "内存利用率: ${usage_mem}%" >> $log_file
	echo "一分钟内负载: ${one_overload}" >> $log_file
	echo "五分钟内负载: ${five_overload}" >> $log_file
	echo "十五分钟内负载: ${fifth_overload}" >> $log_file
	echo "当前温度状态: (${temp}度/${max_temp}度)" >> $log_file
	cp $log_file $info_file
fi

cd $dir"/log/"
files=`ls -l |grep "^-"|wc -l`

if [ $files -gt 100 ];then
	mv *.txt /tmp/
fi
