# Python開発環境を持つdebianイメージ
# 日本語化も設定済み
FROM        kagalpandh/kacpp-dev AS builder
SHELL       [ "/bin/bash", "-c" ]
WORKDIR     /root
ENV         DEBIAN_FORONTEND=noninteractive
# GAWK関連環境変数
ENV         GAWK_VERSION=5.3.2
ENV         GAWK_NAME=gawk-${GAWK_VERSION}
ENV         GAWK_SRC_FILE=${GAWK_NAME}.tar.xz
ENV         GAWK_URL=https://ftp.gnu.org/gnu/gawk/${GAWK_SRC_FILE}
ENV         GAWK_DEST=/usr/local/stow/${GAWK_NAME}
# 開発環境インストール
RUN         apt update && \
            test -d /usr/local/stow  || mkdir /usr/local/stow && \
            # gawkインストール
            wget ${GAWK_URL} && tar -Jxvf ${GAWK_SRC_FILE} && cd ${GAWK_NAME} && \
                ./configure --prefix=/usr/local/stow/${GAWK_NAME} && \
                make && make install  && \
            apt autoremove -y && apt clean && rm -rf /var/lib/apt/lists/*
FROM        kagalpandh/kacpp-ja
SHELL       [ "/bin/bash", "-c" ]
WORKDIR     /root
# GAWK関連環境変数
ENV         GAWK_VERSION=5.3.2
ENV         GAWK_DEST=gawk-${GAWK_VERSION}
# python
ENV         PYTHON_VERSION=3.14.0
ENV         PYTHON_DEST=Python-${PYTHON_VERSION}
ENV         PYTHON_SRC_FILE=${PYTHON_DEST}.tar.xz
ENV         PYTHON_URL=https://www.python.org/ftp/python/${PYTHON_VERSION}/${PYTHON_SRC_FILE}
ENV         PYTHON_HOME=/usr/local/${PYTHON_DEST}
ENV         PATH=${PYTHON_HOME}/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
ENV         LD_LIBRARY_PATH=${PYTHON_HOME}/lib
COPY        sh/apt-install/pydev-dev.txt  /usr/local/sh/apt-install
# 開発環境インストール
RUN         apt update && \
            /usr/local/sh/system/apt-install.sh install gccdev.txt && \
            /usr/local/sh/system/apt-install.sh install pydev-dev.txt && \
            wget ${PYTHON_URL} && tar -Jxvf ${PYTHON_SRC_FILE} && cd ${PYTHON_DEST} && \
                ./configure --prefix=/usr/local/${PYTHON_DEST} --with-ensurepip --enable-shared && \
                make && make install  && \
                apt autoremove -y && apt clean && rm -rf /var/lib/apt/lists/* && \
                cd ../ && rm -rf ${PYTHON_DEST}
FROM        kagalpandh/kacpp-base
SHELL       [ "/bin/bash", "-c" ]
WORKDIR     /root
ENV         PYTHON_VERSION=3.10.8
ENV         PYTHON_DEST=Python-${PYTHON_VERSION}
ENV         PYTHON_HOME=/usr/local/${PYTHON_DEST}
ENV         PATH=${PYTHON_HOME}/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
ENV         LD_LIBRARY_PATH=${PYTHON_HOME}/lib
COPY        --from=builder /usr/local/${PYTHON_DEST}/ ${PYTHON_HOME}
COPY        sh/apt-install/pydev.txt /usr/local/sh/apt-install
COPY        rcprofile /etc/rc.d
RUN         apt update && \
            /usr/local/sh/system/apt-install.sh install pydev.txt && \
            cd /usr/local && ln -s ${PYTHON_DEST} python && \
            echo "/usr/local/python/lib" >>/etc/ld.so.conf && ldconfig && \
            ${PYTHON_HOME}/bin/pip3 install --upgrade setuptools pip && ${PYTHON_HOME}/bin/pip3 install ez_setup && \


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

