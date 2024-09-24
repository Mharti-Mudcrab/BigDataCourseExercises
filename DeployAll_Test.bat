@echo off

echo ========== Deploy interactive pod - Ref: services\interactive ==========
cd /d %~dp0services\interactive
start cmd /k "echo Interactive pod! & kubectl run interactive -i --tty --image registry.gitlab.sdu.dk/jah/bigdatarepo/interactive:latest -- /bin/bash"
::kubectl apply -f interactive.yaml

pause