# GceExperimentExecutor
 gceでコスパよく実験を回すためのスクリプト。
 VMがなければ作ってくれ、あって停止中なら叩き起こしてstartup-scriptを走らせるし動作中なら何も実行しないでくれます。
 このスクリプトをぐるぐる回してオートスケーラーもどきを作ることもできます。

## 構成

- experiment.sh
  
  gcloudコマンドが通る場所で実行するスクリプト。
  METADATAとしてvmを立ち上げたときに実行したい実験ファイルとstartup-scriptを渡している。
  gcloudコマンドを修正してお好みのインスタンスを立てることもできます。

- executor.sh

  vmが立ち上がった後に渡されるstartup-script。vm内での実験の開始から停止までを司る。

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
```sh experiment.sh -i test-vm -e exp001/main.py -g p100 -z us-west1-b -t n1-standard-8```


## なんでこんな構成なの

- 格安で動かしたければGCEのSpotインスタンス+GCSの構成だろう
- ディスクの維持代はかかるものの、毎回GCSからおなじファイルをDLしてくれるよりはこの構成が安く済むだろう
- 純粋に計算時間分のGPU代しかかからないだろうから安く済みそう