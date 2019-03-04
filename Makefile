NAME=registry
NAMESPACE=default
PVC_NAME=${NAME}-pvc
IMAGE=registry:latest
PORT=5000
CLUSTER_IP=10.254.0.50
LOCAL_REGISTRY=${CLUSTER_IP}:${PORT}
MANIFEST=./manifest
MOUNT_PATH=/var/lib/registry
IMAGE_PULL_POLICY=Always

all: deploy

cp:
	@find ${MANIFEST} -type f -name "*.sed" | sed s?".sed"?""?g | xargs -I {} cp {}.sed {}

sed:
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.name}}"?"${NAME}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.pvc.name}}"?"${PVC_NAME}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.namespace}}"?"${NAMESPACE}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.port}}"?"${PORT}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.mount.path}}"?"${MOUNT_PATH}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.cluster.ip}}"?"${CLUSTER_IP}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.image}}"?"${IMAGE}"?g
	@find ${MANIFEST} -type f -name "*.yaml" | xargs sed -i s?"{{.image.pull.policy}}"?"${IMAGE_PULL_POLICY}"?g

deploy: export OP=create
deploy: cp sed
	-@kubectl ${OP} -f ${MANIFEST}/storageclass.yaml
	-@kubectl ${OP} -f ${MANIFEST}/pv.yaml
	-@kubectl ${OP} -f ${MANIFEST}/statefulset.yaml
	-@kubectl ${OP} -f ${MANIFEST}/service.yaml
	-@kubectl ${OP} -f ${MANIFEST}/pvc.yaml

del: export OP=delete
del:
	-@kubectl ${OP} -f ${MANIFEST}/statefulset.yaml
	-@kubectl ${OP} -f ${MANIFEST}/service.yaml
	-@kubectl ${OP} -f ${MANIFEST}/pvc.yaml
	-@kubectl ${OP} -f ${MANIFEST}/pv.yaml
	-@rm -f ${MANIFEST}/statefulset.yaml
	-@rm -f ${MANIFEST}/service.yaml
	-@rm -f ${MANIFEST}/pvc.yaml
clean: del

.PHONY : test
test:
	@curl http://${LOCAL_REGISTRY}/v2/_catalog

test1:
	@docker pull busybox
	@docker tag busybox ${LOCAL_REGISTRY}/busybox
	@docker push ${LOCAL_REGISTRY}/busybox

clean-test:
	@kubectl ${OP} -f ./test/test-claim.yaml -f ./test/test-pod.yaml
