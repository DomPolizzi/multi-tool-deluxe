#!/bin/bash
docker system prune

# Custom VARS
configs=$(docker config ls -q)
secrets=$(docker secret ls -q)

# List all configs
for config in $configs; do
    # Initialize a counter for how many times a config is used
    used=0
    # List all services
    services=$(docker service ls -q)
    for service in $services; do
        # Check if the current service uses the config
        if docker service inspect $service --format '{{ .Spec.TaskTemplate.ContainerSpec.Configs }}' | grep -q $config; then
            used=$((used + 1))
        fi
    done
    # If the config is not used by any service, print its ID
    if [ $used -eq 0 ]; then
        echo "Unused config found: $config, removing config file"
        docker config rm $config
    fi
done


# List all Secrets
for secret in $secrets; do
    # Initialize a flag to indicate if the secret is used
    is_used=false
    # Check each service to see if the secret is used
    services=$(docker service ls -q)
    for service in $services; do
        # If the secret is found in the service's spec, mark as used
        if docker service inspect $service --format '{{ range .Spec.TaskTemplate.ContainerSpec.Secrets }}{{ .SecretName }} {{end}}' | grep -wq $secret; then
            is_used=true
            break
        fi
    done
    # If the secret is unused, print its name
    if [ "$is_used" = false ]; then
        echo "Unused secret: $(docker secret inspect $secret --format '{{ .Spec.Name }}')"
        echo " Removing now: "
        docker secret rm $(docker secret inspect $secret --format '{{ .Spec.Name }}')
    fi
done