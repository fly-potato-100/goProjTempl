#!/bin/bash

:<<Usage

该脚本封装了项目的Go环境，无需设置Go环境变量。
主要提供下面几种用法：

	./proj.conf.d/script/env.sh build Debug
		根据config.ini中的Debug配置（可自行设定）进行完整build

	./proj.conf.d/script/env.sh run "go clean"
		直接包装的go tool命令，如此处的"go clean"

	./proj.conf.d/script/env.sh raw "./bin/xxx"
		直接包装的原始命令（不打印任何log），如某些依赖GOPATH的命令

Usage

### 获取参数
CMD_TYPE=$1
shift
CMD_PARAM="$*"

### 获取Proj绝对路径
PROJ_DIR=$(cd $(dirname $0)/../..;pwd)

### 进入Proj目录进行操作
cd $PROJ_DIR
#echo "$PROJ_DIR"

### 指定Proj配置目录
PROJ_CONF_DIR=proj.conf.d
[ -d "$PROJ_CONF_DIR" ] || exit 1

### 加载脚本
source $PROJ_CONF_DIR/script/def || exit 1
source $PROJ_CONF_DIR/script/func || exit 1

### 清空output目录
#clearLog

### 检查GOROOT是否存在
if [ -z $GOROOT ]; then
	log "FATAL" "`echo_color $CL_YELLOW GOROOT` not found!aborted."
fi

### 根据当前目录重设GOPATH,GOBIN
export GOPATH="$LOCAL_GOPATH"
export GOBIN="$LOCAL_GOBIN"
export PATH+=:$GOBIN

### raw模式下直接运行命令并返回
if [ "$CMD_TYPE" == "raw" ]; then
	eval $CMD_PARAM
	exit $?
else
	log "INFO" "Set project temp GOPATH('''`echo_color $CL_YELLOW $GOPATH`''')."
	log "INFO" "Set project temp GOBIN('''`echo_color $CL_YELLOW $GOBIN`''')."
fi

### 根据CMD_TYPE执行操作
if [ "$CMD_TYPE" == "build" ];then
	buildAll "$CMD_PARAM"
elif [ "$CMD_TYPE" == "run" ];then
	goCmd "$CMD_PARAM"
else
	log "FATAL" "Nothing changed."
fi

### 检查执行结果
ret=$?
if [ $ret -ne 0 ]; then
	log "ERROR" "Failed,retcode=$ret."
else
	log "INFO" "Succeeded."
fi

exit $ret
