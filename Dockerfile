FROM centos:6

RUN yum -y update

# --- install emacs --- #

ARG emacs=emacs-24.5
RUN yum install -y gcc lcurses-devel wget ncurses-devel gpm-libs alsa-lib perl gnutls-devel && yum clean all

ARG work_dir=/tmp/setup
RUN mkdir ${work_dir} && \
    chmod 777 ${work_dir}

RUN cd /etc/yum.repos.d && \
    wget https://gist.githubusercontent.com/AaronTheApe/5540012/raw/5782a8d6a95f76daeed6073dc0c90612fefe2fb3/emacs.repo && \
    yum --disablerepo="*" --enablerepo="emacs" --nogpgcheck -y install emacs-nox

# --- install autoconf --- #

ARG autoconf=autoconf-2.69
RUN yum install -y m4 perl-ExtUtils-MakeMaker && yum clean all

RUN cd ${work_dir} && \
    wget -O - http://ftp.gnu.org/gnu/autoconf/${autoconf}.tar.gz | tar zxf -&& \
    cd ${autoconf} && \
    ./configure && \
    make && \
    make install

# --- install git --- #

ARG git_ver=2.9.0
RUN yum install -y zlib-devel tcl gettext-devel libcurl-devel && yum clean all

RUN cd ${work_dir} && \
    wget -O - https://www.kernel.org/pub/software/scm/git/git-${git_ver}.tar.gz | tar zxf - && \
    cd git-${git_ver} && \
    ./configure --with-curl && \
    make && \
    make install && \
    cd .. && \
    rm -rf git-${git_ver}

# --- install roswell and some common lisp implementations --- #

RUN cd ${work_dir} && \
    git clone -b release https://github.com/roswell/roswell.git && \
    cd roswell && \
    sh bootstrap && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm -rf roswell

# ----------------------------- #
# --- make a developer user --- #

ARG user=dev
ARG user_pass=dev000
RUN yum install -y sudo && yum clean all

RUN adduser ${user} && \
    echo ${user_pass} | passwd ${user} --stdin && \
    echo "${user} ALL=(ALL) ALL" >> /etc/sudoers

USER ${user}
WORKDIR /home/${user}

# --- user settings --- #

ARG emacs_home=/home/${user}/.emacs.d
ARG site_lisp=${emacs_home}/site-lisp
ARG emacs_docs=${emacs_home}/docs

RUN mkdir ${emacs_home} && \
    mkdir ${site_lisp} && \
    mkdir ${emacs_docs} && \
    rm ${HOME}/.emacs

RUN ros install sbcl-bin && \
    ros install sbcl && \
    ros install ccl-bin/1.9

RUN ros use sbcl && \
    ln -s ${HOME}/.roswell/local-projects work

# --- install HyperSpec --- #

ARG hyperspec=HyperSpec-7-0
RUN echo ${user_pass} | sudo -S bash -c "yum install -y w3m && yum clean all"

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

# --- run packages for convenience --- #
RUN echo ${user_pass} | sudo -S bash -c "yum install -y openssh openssh-clients && yum clean all"
