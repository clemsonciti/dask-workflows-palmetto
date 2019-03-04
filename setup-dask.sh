# load required modules
module purge
module load gcc/5.4.0 openmpi/1.10.3 anaconda3/5.1.0

# set up python environment
conda create -y -n dask_env python=3.7
source activate dask_env
conda install -y -c conda-forge dask distributed dask-ml scikit-learn h5py
pip install mpi4py matplotlib ipyparallel

pip install git+git://github.com/dask/dask-mpi.git@eb74a110cfc71d47a014458d4e31708e80179de9

# create an IPython profile for ipycluster
ipython profile create --parallel --profile=mpi
echo "c.HubFactory.ip = '*'" >> ~/.ipython/profile_mpi/ipcontroller_config.py

# set up .jhubrc
echo "module load gcc/5.4.0 openmpi/1.10.3 #setup-dask.sh" >> ~/.jhubrc

# install the kernel for Jupyter notebooks
python -m ipykernel install --user --name dask --display-name "Dask (Python 3.7)"

# convenience script for starting a dask cluster
mkdir -p /home/$USER/bin
echo '#!/usr/bin/env bash
module purge
module load anaconda3/5.1.0
source ~/.jhubrc
source activate dask_env

rm -f ~/dask-scheduler.json
touch ~/dask-scheduler.json

mkdir -p /scratch2/$USER/dask-workers

mpirun dask-mpi --scheduler-port=8088 --worker-port=8093 --nanny-port=8094 --scheduler-file=/home/$USER/dask-scheduler.json --no-nanny --local-directory /scratch2/$USER/dask-workers --interface=ib0' > /home/$USER/bin/start-dask-cluster

chmod u+x /home/$USER/bin/start-dask-cluster
