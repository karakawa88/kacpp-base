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
<!--
ソースパッケッジ管理porgもコンパイルして入れてあり使用可能である。
-->

##構成
管理者用グループadmin(116)と管理者用ユーザーdockeradminを使用できる。
sudoでadminグループはrootでコマンドを実行可能。
<!--
またporgでソースコードからのパッケージ管理もできる。
基本的なコマンドとしてgawkがコンパイルして入れてありporgで情報を見ることができる。
-->

##ベースイメージ
kagalpandh/kacpp-ja

# その他
DockerHub: [kagalpandh/kacpp-base](https://hub.docker.com/repository/docker/kagalpandh/kacpp-base)<br />
GitHub: [karakawa88/kacpp-base](https://github.com/karakawa88/kacpp-ja)

