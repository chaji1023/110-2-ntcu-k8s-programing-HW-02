#!/bin/bash

echo ""
echo "測試刪除Client Deployment後，web Deployment與Service也被刪除"

sa=`for f in ./manifest/*; do cat ${f} | yq '(.|select(.kind == "ServiceAccount")).metadata.name' ; done`
deployment=`for f in ./manifest/*; do cat ${f} | yq "(.|select(.spec.template.spec.serviceAccountName == \"${sa}\")).metadata.name" ; done`


kubectl delete deployments.apps ${deployment} >/dev/null  2>&1

LABEL="ntcu-k8s=hw2"


for i in {1..20}; do
  sleep 1

  svc_num=`kubectl get svc   -l ${LABEL}  -o yaml | yq '.items | length'`
  if [[ "$svc_num" -eq 0 ]]; then
      break
  fi

  if [[ "$i" -eq 20 ]]; then
      echo "client建立的svc數量 $svc_num 不正確"
      exit 1
  fi

done


for i in {1..20}; do
  sleep 1

  deployment_num=`kubectl get deployment -l ${LABEL}  -o yaml | yq '.items | length'`
  if [[ "$deployment_num" -eq 0 ]]; then
      break
  fi

  if [[ "$i" -eq 20 ]]; then
      echo "client建立的deployment 數量 $deployment_num 不正確"
      exit 1
  fi
done


echo "........ PASS"
