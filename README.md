# GceExperimentExecutor
 gceでコスパよく実験を回すためのスクリプト

## 構成

- gcloud_command.sh
  
  叩くgcloudコマンド。セキュリティのために切り出した。

- experiment.sh
  
  gcloudコマンドが通る場所で実行するスクリプト。
  gcloud_command.shの引数部分を管理する。
  METADATAとしてvmを立ち上げたときに実行したい実験ファイルとstartup-scriptを渡している。

- executor.sh

  vmが立ち上がった後に渡されるstartup-script。vm内での実験の開始から終了までを司る。

- .env
  
  token, passwordなど重要な情報は.envファイルに記述。startup-scriptが立ち上がった際に環境変数に格納されます。
  gitignore推奨。
  ex :
  ```
  WANDB=<wandb token>
  GIT_USER=<git user>
  GIT_PASS=<git password>
  GIT_REPO=<git repo>
  ```


## 例: 
```sh experiment.sh -i exp001/main.py -g p100 -z us-west1-b -t n1-standard-8```