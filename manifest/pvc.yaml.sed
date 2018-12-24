kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: {{.pvc.name}}
  namespace: {{.namespace}}
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 100Gi
  storageClassName: nfs-storage
