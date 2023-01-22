# GceExperimentExecutor
 gceでコスパよく実験を回すためのスクリプト

## 構成

- experiment.sh

  gcloudコマンドが通る場所で実行するスクリプト。METADATAとしてvmを立ち上げたときに実行したい実験ファイルとstartup-scriptを渡している。
  "custom here" 以下にお好みのgceの設定を定義してください。

- executor.sh
  
  vmが立ち上がった後に渡されるstartup-script。