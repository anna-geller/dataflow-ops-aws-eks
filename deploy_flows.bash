# upload flow code to S3 storage block + deploy flow as KubernetesJob infra block
python blocks/s3.py
python blocks/k8s.py
prefect deployment build -n prod -q prod -sb s3/prod -ib kubernetes-job/prod -a flows/healthcheck.py:healthcheck
prefect deployment build -n prod -q prod -sb s3/prod -ib kubernetes-job/prod -a flows/parametrized.py:parametrized --skip-upload
prefect deployment build -n prod -q prod -sb s3/prod -ib kubernetes-job/prod -a flows/hello.py:hello --skip-upload
# ---------------------------------------------------------------
# run all flows
prefect deployment run healthcheck/prod
prefect deployment run parametrized/prod
prefect deployment run hello/prod
