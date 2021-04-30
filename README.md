# kagalpandh/kacpp-base ベースとなるDockerイメージ

## 概要
マルチユーザー用にするためにsudoをいれ基本的なコマンドも追加したイメージ。
管理者グループと管理者ユーザーを作成してある。
<!--
またソースコードパッケッジ管理porgも入れてある。
-->

## 使い方
```shell
docker image pull kagalpandh/kacpp-base
docker run -dit --name kacpp-base kagalpandh/kacpp-base
```

## 説明
マルチユーザー用にイメージを作り変え基本的なコマンドを入れてある。
gawk, wgetなど。
ただやっていることはsudoの設定のみである。
管理者用グループadmin(116)と管理者用ユーザーdockeradminを作成してある。
adminグループはsudoをroot権限で実行可能。
APTパッケージをAPTリストファイルをもとにインストール削除するapt-install.shスクリプトがある。

### SH シェルスクリプトディレクトリ
管理用シェルスクリプトが格納されるディレクトリ。
環境変数SHで参照できる。

### apt-install.sh
APTパッケージをAPTリストをもとにインストール・削除するスクリプト。
/usr/local/sh/systemに格納されている。
APTリストは/usr/local/sh/apt-installに配置しAPTパッケージが一行づつ記述されたテキストファイル。
これに先頭行に#でコメントを入れることが可能。
使用方法
```shell
/usr/local/sh/system/apt-install.sh install kacpp-base.txt # インンストール
/usr/local/sh/system/apt-install.sh uninstall kacpp-base.txt # 削除
```
コマンドにinstallかuninstallを指定。
引数に削除・インストールするAPTパッケージのAPTリストファイルを指定するが
指定しない場合はapt-installディレクトリの全てのAPTリストを使用する。

##構成
管理者用グループ
管理者用グループ    admin(116)
管理者用ユーザー    dockeradmin
sudoでadminグループはrootでコマンドを実行可能。

システム用シェルスクリプトディレクトリ  /usr/local/sh

APTリストスクリプト     /usr/local/sh/system/apt-install.sh
APTリストディレクトリ   /usr/local/sh/apt-install
このイメージで使用するのはkacpp-base.txtである。

##ベースイメージ
kagalpandh/kacpp-ja

# その他
DockerHub: [kagalpandh/kacpp-base](https://hub.docker.com/repository/docker/kagalpandh/kacpp-base)<br />
GitHub: [karakawa88/kacpp-base](https://github.com/karakawa88/kacpp-base)

