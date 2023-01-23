# GceExperimentExecutor
 gceでコスパよく実験を回すためのスクリプト

## 構成

- gcloud_command.sh
  
  gcloudコマンドのうち、experiment.shでカスタムしない部分について書く。

- experiment.sh

  gcloudコマンドが通る場所で実行するスクリプト。
  METADATAとしてvmを立ち上げたときに実行したい実験ファイルとstartup-scriptを渡している。

- executor.sh

  vmが立ち上がった後に渡されるstartup-script。vm内での実験の開始から終了までを司る。

- .env
  
  token, passwordなど重要な情報は.envファイルに記述


## 例: 
```sh experiment.sh -i exp001/main.py -g p100 -z us-west1-b -t n1-standard-8```