#jupyter kernelspec remove <kernel_name>   remove python environment
module purge
module load anaconda3/5.1.0

cd
source deactivate
conda env remove -n dask_env

# remove IPython profile
DIR=$(ipython profile locate mpi)

# remove any added lines from .jhubrc
sed -i '/setup-dask.sh/d' /home/$USER/.jhubrc

# uninstall kernel
JUPYTER_PATH="" jupyter kernelspec remove dask

# remove start-dask-cluster and stop-dask-cluster
rm $HOME/bin/start-dask-cluster
