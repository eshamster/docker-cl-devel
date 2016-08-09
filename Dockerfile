FROM centos:7

RUN yum -y update

ARG work_dir=/tmp/setup
RUN mkdir ${work_dir} && \
    chmod 777 ${work_dir}

# --- install emacs --- #

ARG emacs=emacs-24.5
RUN yum install -y gcc lcurses-devel wget ncurses-devel gpm-libs alsa-lib perl gnutls-devel && yum clean all

RUN wget -O - http://ftp.jaist.ac.jp/pub/GNU/emacs/${emacs}.tar.gz | tar zxf - && \
    cd ${emacs} && \
    ./configure --without-x && \
    make && \
    make install && \
    cd .. && \
    rm -rf ${emacs}
 
# --- install newer git --- #

ARG git_ver=2.9.0
RUN yum remove -y git
RUN yum install -y zlib-devel tcl gettext-devel libcurl-devel wget make perl-ExtUtils-MakeMaker && yum clean all

RUN cd ${work_dir} && \
    wget -O - https://www.kernel.org/pub/software/scm/git/git-${git_ver}.tar.gz | tar zxf - && \
    cd git-${git_ver} && \
    ./configure --with-curl && \
    make && \
    make install && \
    cd .. && \
    rm -rf git-${git_ver}

# --- install roswell and some common lisp implementations --- #

RUN yum install -y automake autoconf && yum clean all

RUN cd ${work_dir} && \
    git clone -b release https://github.com/roswell/roswell.git && \
    cd roswell && \
    sh bootstrap && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm -rf roswell

# --- install w3m --- #
# I refered http://qiita.com/imkitchen/items/02a9df7baaaf434fee66 for this.

ARG w3m_ver=0.5.3
RUN yum install -y gcc-c++ gc-devel gettext-devel && yum clean all
COPY w3m-${w3m_ver}.patch ${work_dir}/w3m-${w3m_ver}.patch

RUN cd ${work_dir} && \
    wget -O - "http://sourceforge.net/projects/w3m/files/w3m/w3m-${w3m_ver}/w3m-${w3m_ver}.tar.gz/download" | tar zxf - && \
    cd w3m-${w3m_ver} && \
    git apply ../w3m-${w3m_ver}.patch && \
    ./configure && \
    make && \
    make install

# ----------------------------- #
# --- make a developer user --- #

ARG user=dev
ARG user_pass=dev000
RUN yum install -y sudo && yum clean all
 
RUN adduser ${user} && \
    echo ${user_pass} | passwd ${user} --stdin && \
    echo "${user} ALL=(ALL) ALL" >> /etc/sudoers && \
    echo "Defaults:${user} !requiretty" >> /etc/sudoers

RUN yum install -y bzip2 && yum clean all # for 'ros install'
RUN yum install -y openssh openssh-clients && yum clean all # for convenience

USER ${user}
WORKDIR /home/${user}

# --- user settings --- #

ARG emacs_home=/home/${user}/.emacs.d
ARG site_lisp=${emacs_home}/site-lisp
ARG emacs_docs=${emacs_home}/docs

RUN mkdir ${emacs_home} && \
    mkdir ${site_lisp} && \
    mkdir ${emacs_docs}

RUN ros install sbcl-bin && \
    ros install sbcl && \
    ros install ccl-bin

RUN ros use sbcl && \
    ln -s ${HOME}/.roswell/local-projects work

# --- install HyperSpec --- #

ARG hyperspec=HyperSpec-7-0

RUN cd ${work_dir} && \
    wget -O - ftp://ftp.lispworks.com/pub/software_tools/reference/${hyperspec}.tar.gz | tar zxf - && \
    mv HyperSpec ${emacs_docs}

# --- install slime-repl-color --- #

RUN cd ${site_lisp} && \
    wget https://raw.githubusercontent.com/deadtrickster/slime-repl-ansi-color/master/slime-repl-ansi-color.el

# --- run emacs for installing packages --- #

COPY init.el ${emacs_home}
RUN echo ${user_pass} | sudo -S chown ${user}:${user} ${emacs_home}/init.el
RUN emacs --batch --load .emacs.d/init.el
