#!/bin/bash

##
# 概要: Stowパッケージリストを指定してソースパッケージのインストール・削除を行うスクリプト。
# 説明: Stowパッケージリストとはインストール削除するパッケージが一行毎に格納されたファイル。
#       /usr/local/sh/apt-intstallディレクトリに格納されているものとする。
#       このスクリプトにはコマンドがあり以下のとうり。
#           install     インストール
#           uninstall   削除
#       このコマンドは必ず指定しなくてはいけない。
#       引数はStowパッケージリストファイルを指定し何も指定しない場合は
#       /usr/local/sh/stowディレクトリのリストファイル全てを指定したものとする。
# コマンドの書式
#   stow-install.sh install|uninstall [files...]
# 終了ステータス
#   0   成功
#   1   コマンドが指定されてないか間違ったコマンド名
#   2   Stowパッケージリストが見つからない
#   3   Stowパッケージインストールエラー
#

USAGE_STRING="$0 install|uninstall [files...]"
STOW_LIST_DIR=/usr/local/sh/stow-install


# コマンド処理
STOW_OPTS=" -vv "
STOW_CMD="install"
if [[ $1 == "install" || $1 == "uninstall" ]]
then
    [[ $1 == "uninstall" ]] && STOW_CMD="uninstall"; STOW_OPTS=" -D "
else
    echo "Error: install | uninstallのコマンドは必須です。"
    echo "$USAGE_STRING"
    exit 1
fi
# 引数のファイルのみ必要なためshiftする
shift

# STOWパッケージリストファイルを変数に格納する
# 複数の場合はスペース区切り
files="$@"
if (($# <= 0))
then
    files=$(ls $STOW_LIST_DIR | xargs echo)
fi
echo "$files"

# 複数のSTOWパッケージリストファイルからSTOWのパッケージをインストールする
for file in $files
do
    path="$STOW_LIST_DIR/$file"
    if [[ ! -r "$path" ]]; then
        echo "Error: ファイルが見つかりません。[$path]" 1>&2
        exit 2
    fi
    cat "$path" | grep -E -v '(^#.*)|(^[ \t]*$)' | xargs -I "{}" stow "$STOW_OPTS" "{}"
    if [[ ${PIPESTATUS[2]} -ne 0 ]]
    then
        echo "Error STOWパッケージ$STOW_CMD [$path]" 1>&2
        cat "$path" >2
        exit 3
    fi
done

exit 0
