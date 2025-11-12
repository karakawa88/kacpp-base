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
ENV         STOW_VERSION=2.4.1
ENV         STOW_NAME=stow-${STOW_VERSION}
ENV         STOW_SRC_FILE=${STOW_NAME}.tar.gz
ENV         STOW_URL=https://ftp.gnu.org/gnu/stow/${STOW_SRC_FILE}
ENV         STOW_DEST=/usr/local/stow/${STOW_NAME}

# GAWK
RUN         apt update && \
            test -d /usr/local/stow  || mkdir /usr/local/stow && \
            test -d /usr/local/sh || mkdir /usr/local/sh && \
            # gawkインストール
            wget ${GAWK_URL} && tar -Jxvf ${GAWK_SRC_FILE} && cd ${GAWK_NAME} && \
                ./configure --prefix=/usr/local/stow/${GAWK_NAME} && \
                make && make install  && \
            apt autoremove -y && apt clean && rm -rf /var/lib/apt/lists/* && \
#stow
            wget ${STOW_URL} && tar -zxvf ${STOW_SRC_FILE} && cd ${STOW_NAME} && \
                ./configure --prefix=/usr/local/stow/${STOW_NAME} --datadir=/usr/local/stow && \
                make && make install  && \
            apt autoremove -y && apt clean && rm -rf /var/lib/apt/lists/*
# python
ENV         PYTHON_VERSION=3.14.0
ENV         PYTHON_DEST=Python-${PYTHON_VERSION}
ENV         PYTHON_SRC_FILE=${PYTHON_DEST}.tar.xz
ENV         PYTHON_URL=https://www.python.org/ftp/python/${PYTHON_VERSION}/${PYTHON_SRC_FILE}
ENV         PYTHON_HOME=/usr/local/stow/${PYTHON_DEST}
ENV         PATH=${PYTHON_HOME}/bin:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
ENV         LD_LIBRARY_PATH=${PYTHON_HOME}/lib
COPY        sh/  /usr/local/sh/
# 開発環境インストール
RUN         apt update && \
            /usr/local/sh/system/apt-install.sh install pydev.txt && \
            wget ${PYTHON_URL} && tar -Jxvf ${PYTHON_SRC_FILE} && cd ${PYTHON_DEST} && \
                ./configure --prefix=/usr/local/stow/${PYTHON_DEST} --with-ensurepip --enable-shared && \
                make && make install  && \
                apt autoremove -y && apt clean && rm -rf /var/lib/apt/lists/* && \
                cd ../ && rm -rf ${PYTHON_DEST}

FROM        kagalpandh/kacpp-ja
SHELL       [ "/bin/bash", "-c" ]
WORKDIR     /root
# GAWK関連環境変数
ENV         GAWK_VERSION=5.3.2
ENV         GAWK_DEST=gawk-${GAWK_VERSION}
SHELL       [ "/bin/bash", "-c" ]
WORKDIR     /root
# Python環境変数
ENV         PYTHON_VERSION=3.14.0
ENV         PYTHON_DEST=Python-${PYTHON_VERSION}
ENV         PYTHON_HOME=/usr/local/${PYTHON_DEST}
ENV         STOW_VERSION=2.4.1
ENV         STOW_NAME=stow-${STOW_VERSION}
ENV         STOW_DEST=/usr/local/stow/${STOW_NAME}
ENV         SH=/usr/local/sh
ENV         PATH=${PYTHON_HOME}/bin:${SH}/system:/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
RUN         mkdir /usr/local/sh && mkdir /usr/local/stow
COPY        --from=builder /usr/local/stow/ /usr/local/stow
COPY        sh/ /usr/local/sh
RUN         apt update && \
            find ${SH} -name "*.sh" -exec chmod 775 {} \; && \ 
            find ${SH} -type d -exec chmod 3775 {} \; && \
            apt update && \
            /usr/local/sh/system/apt-install.sh install kacpp-base.txt && \
            cp -rf $STOW_DEST/* /usr/local && rm -rf $STOW_DEST && \
            mv /usr/local/stow/${PYTHON_DEST} /usr/local/ && \
            cd /usr/local && ln -s ${PYTHON_DEST} python && \
            find /usr/local/python/bin -type f -exec chmod 775 {} \; && \
            /usr/local/sh/system/stow-install.sh install kacpp-base.txt && \
            echo "/usr/local/python/lib" >>/etc/ld.so.conf && ldconfig && \
            #${PYTHON_HOME}/bin/pip3 install --upgrade setuptools pip && ${PYTHON_HOME}/bin/pip3 install ez_setup && \
            apt autoremove -y && apt clean && rm -rf /var/lib/apt/lists/*


# 管理者用グループとユーザー関連環境変数
# ENV         ADMIN_GID=116
# ENV         ADMIN_GROUP_NAME=admin
# ENV         ADMIN_USER_NAME=dockeradmin
# APTインストール・削除スクリプト環境変数
# シェルスクリプトディレクトリ
COPY        rc.d /etc/rc.d
COPY        skel/*  /etc/skel
COPY        sh/ /usr/local/sh
RUN         groupadd admin && \
            chown -R root:admin ${SH} && \
            #終了処理 
            cd ~/ && apt autoremove -y && apt clean && rm -rf /var/lib/apt/lists/*

