import boto3

from prefect.deployments import Deployment
from prefect.filesystems import RemoteFileSystem
from prefect.flows import Flow
from prefect.flow_runners import KubernetesFlowRunner
from prefect.packaging import FilePackager, OrionPackager
from prefect.orion.schemas.schedules import CronSchedule


def deploy_to_kubernetes(
    flow: Flow,
    name: str = None,  # deployment name suffix
    cron_schedule: str = None,
    timezone: str = "America/New_York",
    log_level: str = "DEBUG",
    namespace: str = "prefect-prod-eks",
    store_flow_in_orion_db: bool = False,
    s3_bucket: str = "prefectdata",
    flow_runner: KubernetesFlowRunner = None,
    **kwargs,
) -> Deployment:

    deployment_name = f"{namespace}_{name}" if name else namespace
    packager = (
        OrionPackager()
        if store_flow_in_orion_db
        else FilePackager(
            filesystem=RemoteFileSystem(basepath=f"s3://{s3_bucket}/flows")
        )
    )
    sts = boto3.client("sts")
    default_region = sts.meta.region_name
    aws_account_id = sts.get_caller_identity().get("Account")
    k8s_flow_runner = (
        flow_runner
        if flow_runner
        else KubernetesFlowRunner(
            namespace=namespace,
            env=dict(PREFECT_LOGGING_LEVEL=log_level),
            image=f"{aws_account_id}.dkr.ecr.{default_region}.amazonaws.com/{namespace}",
        )
    )
    if cron_schedule:
        return Deployment(
            flow=flow,
            name=deployment_name,
            tags=[namespace],
            schedule=CronSchedule(cron=cron_schedule, timezone=timezone),
            packager=packager,
            flow_runner=k8s_flow_runner,
            **kwargs,
        )
    else:
        return Deployment(
            flow=flow,
            name=deployment_name,
            tags=[namespace],
            packager=packager,
            flow_runner=k8s_flow_runner,
            **kwargs,
        )
