# Python開発環境を持つdebianイメージ
# 日本語化も設定済み
FROM        kagalpandh/kacpp-gccdev AS builder
SHELL       [ "/bin/bash", "-c" ]
WORKDIR     /root
ENV         DEBIAN_FORONTEND=noninteractive
# GAWK関連環境変数
ENV         GAWK_VERSION=5.2.0
ENV         GAWK_NAME=gawk-${GAWK_VERSION}
ENV         GAWK_SRC_FILE=${GAWK_NAME}.tar.xz
ENV         GAWK_URL=https://ftp.gnu.org/gnu/gawk/${GAWK_SRC_FILE}
ENV         GAWK_DEST=/root/${GAWK_NAME}
# 開発環境インストール
RUN         apt update && \
            # gawkインストール
            wget ${GAWK_URL} && tar -Jxvf ${GAWK_SRC_FILE} && cd ${GAWK_NAME} && \
                ./configure --prefix=/usr/local/${GAWK_NAME} && \
                make && make install  && \
            apt autoremove -y && apt clean && rm -rf /var/lib/apt/lists/*
FROM        kagalpandh/kacpp-ja
SHELL       [ "/bin/bash", "-c" ]
WORKDIR     /root
# GAWK関連環境変数
ENV         GAWK_VERSION=5.2.0
ENV         GAWK_DEST=gawk-${GAWK_VERSION}
# 管理者用グループとユーザー関連環境変数
# ENV         ADMIN_GID=116
# ENV         ADMIN_GROUP_NAME=admin
# ENV         ADMIN_USER_NAME=dockeradmin
# APTインストール・削除スクリプト環境変数
# シェルスクリプトディレクトリ
ENV         SH=/usr/local/sh
ENV         PATH=${SH}/system:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
COPY        --from=builder /usr/local/${GAWK_DEST}/ /usr/local
COPY        skel/*  /etc/skel
RUN         mkdir /usr/local/sh
COPY        sh/ /usr/local/sh
# COPY        rcprofile /etc/rc.d
RUN         apt update && \
            # 基本的なパッケージのインストール
            # パッケージのリストは/usr/local/sh/apt-install/kacpp-base.txtにある。
            $SH/system/apt-install.sh install kacpp-base.txt && \
            echo "/usr/local/lib" >>/etc/ld.so.conf && ldconfig && \
            # SHディレクトリ
            chown -R root.admin ${SH} && \
                find ${SH} -name "*.sh" -exec chmod 775 {} \; && \ 
                find ${SH} -type d -exec chmod 3775 {} \; && \
            #終了処理 
            cd ~/ && apt autoremove -y && apt clean && rm -rf /var/lib/apt/lists/*

