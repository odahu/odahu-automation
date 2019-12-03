FROM jupyter/base-notebook:lab-1.1.3
SHELL ["/bin/bash", "-c"]
USER 0

RUN pip install jupyterlab-git jupytext==1.1.7 && \
    jupyter serverextension enable --py jupyterlab_git && \
    jupyter nbextension install --py jupytext && \
    jupyter nbextension enable --py jupytext && \
    wget https://nexus.ailifecycle.org/repository/main-npm/odahu-flow-jupyterlab-plugin/-/odahu-flow-jupyterlab-plugin-1.0.0.tgz && \
    jupyter labextension install odahu-flow-jupyterlab-plugin-1.0.0.tgz && \
    rm odahu-flow-jupyterlab-plugin-1.0.0.tgz

