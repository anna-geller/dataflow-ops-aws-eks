# local storage + local process infra block explicit (self-created block)
prefect deployment build flows/parametrized.py:parametrized --name process -q prod -t project -o deploy/process.yaml -ib process/prod -v GITHUB_SHA
prefect deployment apply deploy/process.yaml
prefect deployment run parametrized/process

# local storage + local process infra block explicit with --override (self-created block)
prefect deployment build flows/parametrized.py:parametrized --name process2 -q prod -t project -o deploy/process2.yaml -ib process/prod --override env.PREFECT_LOGGING_LEVEL=DEBUG -v GITHUB_SHA --apply
prefect deployment run parametrized/process2

# local storage + local process (anonymous block created automatically during build)
prefect deployment build flows/parametrized.py:parametrized --name anonymous -q prod -t project -o deploy/anonymous.yaml -v GITHUB_SHA --infra process --apply
prefect deployment run parametrized/anonymous

# s3/prod block + local process (anonymous block created automatically during build)
prefect deployment build flows/parametrized.py:parametrized --name s3 -q prod -t project -o deploy/s3.yaml -sb s3/prod -v GITHUB_SHA --apply
prefect deployment run parametrized/s3

# K8s
prefect deployment build flows/parametrized.py:parametrized --name k8s -q prod -t poc -o deploy/k8s.yaml -ib kubernetes-job/prod -sb s3/prod --apply
prefect deployment run parametrized/k8s

# multiple paths
prefect deployment build flows/parametrized.py:parametrized --name s3v1 -q prod -t project -o deploy/s3v1.yaml -sb s3/prod/v1 -v v1 --apply
prefect deployment run parametrized/s3v1

prefect deployment build flows/parametrized.py:parametrized --name s3v2 -q prod -t project -o deploy/s3v2.yaml -sb s3/prod/v2 -v v2 --apply
prefect deployment run parametrized/s3v2


# gcs/prod block + local process (anonymous block created automatically during build)
prefect deployment build flows/parametrized.py:parametrized --name gcs -q prod -t project -o deploy/gcs.yaml -sb gcs/prod -v GITHUB_SHA --apply
prefect deployment run parametrized/gcs

# azure/prod block + local process (anonymous block created automatically during build)
prefect deployment build flows/parametrized.py:parametrized --name az -q prod -t project -o deploy/az.yaml -sb azure/prod -v GITHUB_SHA --apply
prefect deployment run parametrized/az

# simple scheduled flow with interval
prefect deployment build flows/parametrized.py:parametrized --name interval -q prod -t project -o deploy/interval.yaml --interval 5 --apply

# simple scheduled flow with CRON
prefect deployment build flows/parametrized.py:parametrized --name cron -q prod -t project -o deploy/cron.yaml --cron "*/1 * * * *" --apply

# to create flow runs from that deployment every hour but only during business hours.
prefect deployment build flows/parametrized.py:parametrized --name rrule -q prod --tag myproject -o deploy/rrule.yaml --rrule "FREQ=HOURLY;BYDAY=MO,TU,WE,TH,FR,SA;BYHOUR=9,10,11,12,13,14,15,16,17"


# GH
python blocks/github.py
prefect deployment build flows/parametrized.py:parametrized --name gh -q prod -sb github/main -o gh.yaml --apply
prefect deployment build flows/hello.py:hello --name gh -q prod -sb github/main -o gh2.yaml --apply

prefect deployment build flows/parametrized.py:parametrized -n noupload -q prod -sb s3/prod -o deploy/noupload.yaml --skip-upload --apply

# ----------------------------------------------------------------------------------------------------------
# parametrization
# this should fail
prefect deployment build flows/parametrized.py:parametrized -n kv -q prod -o deploy/json.yaml --apply --param user=Anna --param answer=7 --params '{"user": "Brooklyn", "answer": 99}'
# Can only pass one of `param` or `params` options
prefect deployment build flows/parametrized.py:parametrized -n default -q prod -o deploy/json.yaml --apply
prefect deployment run parametrized/default

prefect deployment build flows/parametrized.py:parametrized -n json -q prod -o deploy/json.yaml --apply --params '{"user": "Brooklyn", "answer": 99}'
prefect deployment run parametrized/json

prefect deployment build flows/parametrized.py:parametrized -n kv -q prod -o deploy/json.yaml --apply --param user=Anna --param answer=7
prefect deployment run parametrized/kv

# ----------------------------------------------------------------------------------------------------------
# scheduling
prefect deployment set-schedule --cron '15 20 * * WED' --timezone 'Europe/Berlin' parametrized/default
prefect deployment set-schedule --interval 60 parametrized/default
