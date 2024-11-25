#  ASR语音识别SDK

此仓库为ASR语音识别iOS版本的仓库,包含实时语音识别,一句话识别和录音文件识别极速版三个SDK及相关Demo

## CI/CD

仓库使用工蜂自带的流水线,每次提交均会进行构建,修改仓库内.ci/build.yml文件内容可以改变流水线流程

## 发版说明

1. 当需要发版时,请按以下的方法产生一个特定的提交

   1. 提交信息为版本号,格式为vx.x.x(例如v3.0.0)

   2. 提交内容包含"cloud-asr-sdk-ios/sdk_version.h"版本号更新,需与提交信息一致."更新日志.md"增加更新内容,请勿修改其余文件及内容,(可通过修改Makefile里WRITE_VERSION后运行make version修改版本)

2. 提交后需从流水线获取相关产物作为对外发布SDK,发布的SDK需上传到[COS](https://console.cloud.tencent.com/cos/bucket/setting?bucket=sdk-1300466766&region=ap-shanghai&path=%252Fasr_sdk%252F)

   1. 控制台发布,在[无极](https://public.wuji.woa.com/p/edit?appid=SDKDownloadConfig&schemaid=ASRSdkConfig&nsid=_all)上配置发布

   2. Cocoapods发布,运行make cocoapods即可发版



## 注意事项

1. 一定不要将secret_key和secret_id等密钥推送到仓库