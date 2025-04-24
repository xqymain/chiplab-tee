# 读取寄存器值
# 调用示例: ReadReg 1c000000
proc ReadReg { address } {
    create_hw_axi_txn read_txn [get_hw_axis hw_axi_1] -address $address -type read
    run_hw_axi  read_txn
    set read_value [lindex [report_hw_axi_txn  read_txn] 1];
    delete_hw_axi_txn read_txn
    set tmp addr=0x
    append tmp $address
    append tmp , data=0x
    append tmp $read_value
    return $tmp
}

# 写寄存器值
# 调用示例: WriteReg 1c000000 00000000
proc WriteReg { address data } {
    create_hw_axi_txn write_txn [get_hw_axis hw_axi_1] -address $address -data $data -type write
    run_hw_axi  write_txn
    set write_value [lindex [report_hw_axi_txn  write_txn] 1];
    delete_hw_axi_txn write_txn
}

# 读取寄存器值并写入文件的函数
# 调用示例: ReadRegsToFile 0x1c000000 10 ../log.txt 
proc ReadRegsToFile { start_addr num_regs filename } {
    # 检查文件是否存在,不存在则创建
    if {![file exists [file dirname $filename]]} {
        file mkdir [file dirname $filename]
        puts "Create a directory: [file dirname $filename]"
    }
    
    # 打开文件用于写入
    if {[catch {open $filename "w"} outfile]} {
        puts "Error: Unable to create or open a file $filename"
        return
    }
    
    # 从起始地址开始循环读取指定数量的寄存器
    for {set i 0} {$i < $num_regs} {incr i} {
        # 计算当前地址
        set curr_addr [format "0x%08x" [expr $start_addr + $i * 4]]
        
        # 读取当前地址的值
        create_hw_axi_txn read_txn [get_hw_axis hw_axi_1] -address $curr_addr -type read
        run_hw_axi read_txn
        set read_value [lindex [report_hw_axi_txn read_txn] 1]
        delete_hw_axi_txn read_txn
        
        # 写入文件:地址和数据
        puts $outfile [format "addr=%s, data=0x%s" $curr_addr $read_value]
    }
    
    # 关闭文件
    close $outfile
    puts "Finish"
}

# 打开二进制文件用于读取
set bin_file [open "../inst_data.bin" "rb"]
# 初始地址0x1c000000
set addr_d 469762048
set addr_h [format "%08x" $addr_d ]
set addr $addr_h
# 复位处理器核
WriteReg 80000000 00000000
# 每次读取4个字节直到文件结束
while {![eof $bin_file]} {

    # 读取4字节数据
    set data0 [read $bin_file 1]
    set data1 [read $bin_file 1]
    set data2 [read $bin_file 1]
    set data3 [read $bin_file 1]
    
    # 如果读取的数据不足4字节,跳出循环
    if {[string length $data3] != 1} {
        break
    }
    
    #将data字符串转换为2个16进制数据
    binary scan $data0 H2 var0
    binary scan $data1 H2 var1
    binary scan $data2 H2 var2
    binary scan $data3 H2 var3

    #将16进制数据格式化为字符串
    set vars0 $var0;
    set vars1 $var1;
    set vars2 $var2;
    set vars3 $var3;
    set value [format "%s%s%s%s" $vars3 $vars2 $vars1 $vars0]
    
    # 写入
    WriteReg $addr $value

    # 地址自增4
    incr addr_d 4
    set addr_h [format "%08x" $addr_d ]
    set addr $addr_h
}
# 撤销复位
WriteReg 40000000 00000000
# 关闭文件
close $bin_file