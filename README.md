# COAT

This is the experiment code and result for COAT (Container OverlAy TCP) enhanced stateful container migration under COAT network architecture (as the figure below shows).

![COAT architecture](./attachments/COAT_architecture.png){width=80%}

For the detail of this study, please find in our publication:

    @inproceedings{yu2023tcp,
        title={Tcp connection management for stateful container migration at the network edge},
        author={Yu, Yenchia and Calagna, Antonio and Giaccone, Paolo and Chiasserini, Carla Fabiana},
        booktitle={2023 21st Mediterranean Communication and Computer Networking Conference (MedComNet)},
        pages={151--157},
        year={2023},
        organization={IEEE}
    }

## Requirements
Operating system:
* Ubuntu 20.04 with kernel 5.8.18-050818-generic

Softwares:
* Podman 4.4.0
* runc 1.1.6
* CRIU 3.16.1
