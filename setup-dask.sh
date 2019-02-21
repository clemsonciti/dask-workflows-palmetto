# load required modules
module purge
module load gcc/5.4.0 openmpi/1.10.3 anaconda3/5.1.0

# set up python environment
conda create -y -n dask_env python=3.7
source activate dask_env
conda install -y dask dask-ml scikit-learn
pip install mpi4py matplotlib ipyparallel

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
source ~/.jhubrc
source activate dask_env

dask-scheduler --port=8088 --interface=eth0 --scheduler-file=/home/$USER/dask-scheduler.json&

sleep 10

for NODE in `uniq $PBS_NODEFILE`
do
    ssh $NODE "module load anaconda3 && source activate dask_env && dask-worker --interface=eth0 --nanny-port=8091 --worker-port=8092 --scheduler-file=/home/$USER/dask-scheduler.json"&
done' > /home/$USER/bin/start-dask-cluster

echo '#!/usr/bin/env bash
source ~/.jhubrc
source activate dask_env

for NODE in `uniq $PBS_NODEFILE`
do
    ssh $NODE "killall dask-worker"&
done

sleep 10

killall dask-scheduler' > /home/$USER/bin/stop-dask-cluster

chmod u+x /home/$USER/bin/start-dask-cluster
chmod u+x /home/$USER/bin/stop-dask-cluster
