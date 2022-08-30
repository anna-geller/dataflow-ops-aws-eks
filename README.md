# Prefect agent on EKS
Project demonstrating how to automate Prefect 2.0 deployments to AWS EKS

The project can be used both as monorepo or as a template for a per-project repository

Assumption:
- dev = either a separate Cloud 2.0 workspace or a self-hosted Orion
- prod = [Cloud 2.0](https://app.prefect.cloud/) (free version is sufficient to reproduce the setup shown here) 

The environment deployed as part of this branch can be used as production environment
