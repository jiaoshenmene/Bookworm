#!/bin/bash
#作者:查昊  2016-7-5
#邮箱:zhahao520@163.com
#使用前须知:
#	重要: 先要给脚本设置权限  chmod +x 脚本
#这个脚本是基于gym->fastlane的,不是xcodebuild,所以要先安装gym,只能打包workspace工程

#注意:先要设置脚本权限: chmod +x 脚本.sh

#安装的3个步骤,先检查ruby是否是淘宝镜像,国内会被墙!你懂得!
#然后安装gym,最后安装fir,都只需安装一次
#======================================================
#       1.替换ruby镜像为淘宝
#   $ gem sources --remove https://rubygems.org/
#   $ gem sources -a https://ruby.taobao.org/
#   $ gem sources -l
#   *** CURRENT SOURCES ***
#
#   https://ruby.taobao.org // 确定只有这一个
#
#=====================================================
#       2.安装gym
#   $ sudo gem install gym
#=====================================================
#       3.安装fir
#   $ sudo gem install fir-cli
#=====================================================


#定义usage
usage="Bookworm"

#定义文字颜色
RED='\033[31m'
ESC='\033[0m'

#帮助
if [ "$1" == "--help" ];then
	echo ${usage}
	exit 1
fi

#工程路径
project_path=$1
echo $project_path
#切换到工程目录
cd $project_path
#workspace名称
workspace_name=emty_name
#遍历获取.xcworkspace文件
for file in `ls .`
do
	if [ `echo $file |grep ".xcworkspace"|wc -l` -eq 1 ]
	then
			workspace_name=${file}
	fi
done

#没有找到.xcworkspace文件,退出
[ "$workspace_name" == "emty_name" ] &&{
	echo "Error: ${project_path} is not a iOS project directory!Please check and try again!"
	exit 1
} 

#.xcworkspace的绝对路径
workspace_path=${project_path}/${workspace_name}
#创建日志路径
log_path=${project_path}/xcodebuild.log
if [ -f ${log_path} ]
then
		cat /dev/null >${log_path}
else
		touch ${log_path}
fi

#获取scheme
xcrun xcodebuild -list -workspace ${workspace_path} &>${log_path} 2>/dev/null
#删除掉无用的信息
schemes_str=`cat ${log_path} |grep -v "Schemes:"|grep -v "Information about workspace"`
#创建scheme数组
schemes_array=($schemes_str)

#创建索引,并拼接提示信息
index=0
echo "All schemes information about ${workspace_name}:"
for scheme in ${schemes_str}
do
	let index=index+1
	echo "	${index}.${scheme}"
done
echo "	q:Quit!"

#删除日志文件
rm -f ${log_path}
#读取用户输入
read -p ">>> Please input what index of schemes you want to build,like as 1 2 3<<<" selected_schemes
#如果是q,直接退出
[ "${selected_schemes}" == "q" ]&& exit 1

#遍历输入的数组,排除异常
for scheme in ${selected_schemes}
do
	expr 1 + ${scheme} &>/dev/null
	if [ $? -ne 0 ]
  then
    echo "Error: Please input number and > 0 !"
    exit 1
	fi

	[ ${scheme} -le ${index} -a ${scheme} -gt 0 ]|| {
		echo "Error: Can not found index ${scheme} in schemes!"
		exit 1
	}
done 

#设置fir_token,去fir官网获取
fir_token=""
#获取执行命令时的commit message
#commit_msg="$1"
#询问是否上传到FIR
read -p "=========   Do you want upload to fir? (y/n)   ========" upload_fir

#取当前时间字符串添加到文件结尾
now=$(date +"%Y-%m-%d-%H-%M-%S")

#指定要打包的配置名,默认Release模式
#configuration="Release"
#指定打包所使用的输出方式，目前支持app-store, package, ad-hoc, enterprise, development, 和developer-id，即xcodebuild的method参数
export_method='enterprise'

#指定输出路径
output_path=${project_path}/buildPackages
#archive文件夹
archive_path_pre=${output_path}/Archives
#IPA文件夹
ipa_path_pre=${output_path}/IPAs

#打包前对所有参数进行有效性检查
if [ $# -gt 1 ];then
	echo "Parameter is only project path, you should check parameter!"
	echo ${usage}
	exit 1
fi

#创建文件夹
if [ ! -d ${output_path} ];then
	mkdir -p ${output_path}
fi

if [ ! -d ${archive_path_pre} ];then
	mkdir -p ${archive_path_pre}
fi

if [ ! -d ${ipa_path_pre} ];then
	mkdir -p ${ipa_path_pre}
fi

#输出设定的变量值
#echo "===workspace path: ${workspace_path}==="
#echo "===archive path: ${archive_path}==="
#echo "===ipa path: ${ipa_path}==="
#echo "===export method: ${export_method}==="

#计时
SECONDS=0

#根据索引获取对应的scheme,并开始打包
for scheme in ${selected_schemes}
do
	xcrun xcodebuild -list -workspace ${workspace_path} &>/dev/null 2>/dev/null
	target_name=${schemes_array[${scheme}]}
	
	#指定输出归档文件地址
	archive_path="${archive_path_pre}/${target_name}_${now}.xcarchive"
	#指定输出ipa地址
	ipa_path=${ipa_path_pre}
	#指定输出ipa名称
	ipa_name="${target_name}_${now}.ipa"
	
	#先清空前一次build
	gym --workspace ${workspace_path} \
    --scheme ${target_name} \
    --clean \
    --archive_path ${archive_path} \
    --export_method ${export_method} \
    --output_directory ${ipa_path} \
    --output_name ${ipa_name}


	#是否选择上传到FIR
	[ "${upload_fir}" == "y" -o "${upload_fir}" == "Y" ] && {
		echo -e "${RED}	===Begain upload ${target_name} to fir ...===${ESC}"
		#上传到fir
		fir publish ${ipa_path}/${ipa_name} -T ${fir_token}
	
		if [ $? -eq 0 ]
		then
			echo -e "${RED}	===Successful upload ${target_name} to fir ...===${ESC}"
		else
			echo -e "${RED}	===Failed upload ${target_name} to fir ...===${ESC}"
		fi
	}
	#删除.app.dSYM.zip文件
	rm -f ${ipa_path}/*.app.dSYM.zip
done
 
#输出总用时
echo "===Finished. Total time: ${SECONDS}s==="