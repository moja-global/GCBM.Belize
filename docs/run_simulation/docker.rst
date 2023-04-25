On Docker 
=========

Install Docker and docker-compose based on your `operating system <https://docs.docker.com/engine/install/>`_ . 




Steps to run the Belize simulation in a docker environment 


1. Clone the `gcbm-container` branch of `GCBM Belize <https://github.com/moja-global/GCBM.Belize/tree/gcbm-container>`_  using the command

..  code-block:: bash

       git clone -b gcbm-container https://github.com/moja-global/gcbm.belize


2. Navigate into `GCBM.Belize`

..  code-block:: bash

       cd gcbm.belize


3. Use docker-compose to build the image

..  code-block:: bash

       docker-compose up -d


4. Run the container using the command

..  code-block:: bash

       docker exec -it gcbm-belize /bin/bash


5. Inside the running docker container, run

..  code-block:: bash

       cd /server/gcbm_project


6. Start the simulation using

..  code-block:: bash

       /opt/gcbm/moja.cli --config_file gcbm_config.cfg --config_provider provider_config.json


If there are existing images cached on your machine you may need to docker pull ghcr.io/moja-global/rest_api_gcbm:master 
and build the container using `docker-compose -d --force-recreate`