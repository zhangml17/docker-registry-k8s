apiVersion: v1
kind: Service
metadata:
  namespace: {{.namespace}}
  labels:
    component: {{.name}} 
  name: {{.name}}
spec:
  clusterIP: {{.cluster.ip}} 
  selector:
    component: {{.name}}
  ports:
    - port: {{.port}} 
      targetPort: {{.port}} 
      name: http 
