#!/bin/bash

##
# 概要: APTパッケージリストを指定してAPTパッケージのインストール・削除を行うスクリプト。
# 説明: APTパッケージリストとはインストール削除するパッケージが一行毎に格納されたファイル。
#       /usr/local/sh/apt-intstallディレクトリに格納されているものとする。
#       このスクリプトにはコマンドがありいかのとうり。
#           install     インストール
#           uninstall   削除
#       このコマンドは必ず指定しなくてはいけない。
#       引数はAPTパッケージリストファイルを指定し何も指定しない場合は
#       /usr/local/sh/apt-installディレクトリのリストファイル全てを指定したものとする。
# コマンドの書式
#   apt-install.sh install|uninstall [files...]
# 終了ステータス
#   0   成功
#   1   コマンドが指定されてないか間違ったコマンド名
#   2   APTパッケージリストが見つからない
#   3   APTパッケージインストールエラー
#

USAGE_STRING="$0 install|uninstall [files...]"
APT_LIST_DIR=/usr/local/sh/apt-install

# コマンド処理
APT_OPTS=" -y "
APT_CMD="install"
if [[ $1 == "install" || $1 == "uninstall" ]]
then
    [[ $1 == "uninstall" ]] && APT_CMD="remove"; APT_OPTS=" --purge -y "
else
    echo "Error: install | uninstallのコマンドは必須です。"
    echo "$USAGE_STRING"
    exit 1
fi
# 引数のファイルのみ必要なためshiftする
shift

# APTパッケージリストファイルを変数に格納する
# 複数の場合はスペース区切り
files=$@
if (($# <= 0))
then
    files=$(ls $APT_LIST_DIR | xargs echo)
fi
echo $files

# 複数のAPTパッケージリストファイルからAPTのパッケージをインストールする
for file in $files
do
    path="$APT_LIST_DIR/$file"
    if [[ ! -r "$path" ]]; then
        echo "Error: ファイルが見つかりません。[$path]" 1>&2
        exit 2
    fi
    cat $path | grep -E -v '(^#.*)|(^[ \t]*$)' | xargs apt $APT_CMD $APT_OPTS
    if [[ ${PIPESTATUS[2]} -ne 0 ]]
    then
        echo "Error APTパッケージインストールエラー [$path]" 1>&2
        cat $path >2
        exit 3
    fi
done

exit 0
