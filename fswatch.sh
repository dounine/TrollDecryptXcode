#!/bin/bash
# 监听的目录路径
directory_to_watch="./TrollDecryptXcode"

# 执行的命令
command_to_execute="cd $directory_to_watch && make package"

# 使用 fswatch 监听目录中所有文件的变化并执行命令
#fswatch -r "$directory_to_watch" | xargs -n1 -I{} $command_to_execute
#fswatch -r "$directory_to_watch" | $command_to_execute
while true;do fswatch -1 . && make package;sleep 1;done
