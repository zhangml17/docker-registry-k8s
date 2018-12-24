apiVersion: apps/v1beta1
kind: StatefulSet
metadata:
  namespace: {{.namespace}}
  name: {{.name}}
spec:
  serviceName: "{{.name}}"
  podManagementPolicy: Parallel
  replicas: 1
  template:
    metadata:
      labels:
        component: {{.name}}
    spec:
      terminationGracePeriodSeconds: 10
      containers:
        - name: {{.name}}
          image: {{.image}}
          imagePullPolicy: {{.image.pull.policy}}
          env:
            - name: POD_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.podIP
            - name: POD_NAMESPACE
              valueFrom:
                fieldRef:
                  fieldPath: metadata.namespace
          ports:
            - containerPort: {{.port}} 
              name: http
          volumeMounts:
            - name: host-time
              mountPath: /etc/localtime
              readOnly: true
            - name: {{.pvc.name}}
              mountPath: {{.mount.path}}
      volumes:
        - name: host-time
          hostPath:
            path: /etc/localtime
        - name: {{.pvc.name}}
          persistentVolumeClaim:
            claimName: {{.pvc.name}}
