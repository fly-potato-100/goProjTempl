##! Usage：
##! 本Makefile中包装了Go项目的go tool命令，无需设置GOPATH、GOBIN等环境变量
##! 请直接在项目根目录运行make命令
##! 如需自定义编译配置，请在proj.conf.d/config.ini和proj.conf.d/conf.tpl/下自定ini文件
##! 根据下面的示例选择命令执行
##! -------------------------------------------------

### 核心的运行脚本
PROJ_ENV_SH="./proj.conf.d/script/env.sh"
### 关闭make的verbose模式
#MAKEFLAGS += --silent

##! make [help]: 打印Usage
help: Makefile
	@echo
	@sed -n 's/^##! //p' $< | column -t -s ':' | sed -e 's/^/ -\t/'
	@echo

##! make all: 等同于'''make clean build-debug build-release'''
all: clean build-debug build-release

##! make build-debug: 等同于'''make build conf=Debug'''
build-debug:
	@$(MAKE) build conf="Debug"

##! make build-release: 等同于'''make build conf=Release'''
build-release:
	@$(MAKE) build conf="Release"

##! make build conf="Debug Release1 Release2": 根据config.ini中的配置进行build，可同时指定多个，如"Debug"、"Release"等
build:
	@$(foreach c,$(conf),$(PROJ_ENV_SH) build "$(c)";)

##! make clean: 清除go clean，并删除bin目录
clean:
	@$(MAKE) exec cmd="go clean"
	rm -rf bin .output.log

##! make exec cmd="go build xxx": 执行原生的go tool命令，如"go build xxx"
exec:
	@$(PROJ_ENV_SH) run "$(cmd)"

##! make exec-raw cmd="./bin/xxx": 执行原生的任何命令，如依赖GOPATH的工具
exec-raw:
	@$(PROJ_ENV_SH) raw "$(cmd)"

.PHONY: help clean build
