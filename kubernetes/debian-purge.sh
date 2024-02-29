#!/bin/sh

# Safety prompt to ensure the user wants to proceed
echo "WARNING: This script will remove Kubernetes, Docker, and Containerd from your system."
echo "This action is irreversible and may affect other applications if they depend on Docker or Containerd."
read -p "Are you sure you want to proceed? (y/N): " confirmation

case $confirmation in
    [Yy]* )
        # Stop services before removing packages and configurations
        echo "Stopping Kubernetes services..."
        systemctl stop kubelet
        systemctl stop docker
        systemctl stop containerd

        # Kube Admin Reset
        echo "Resetting Kubernetes using kubeadm..."
        kubeadm reset -f --v=0

        # Remove Kubernetes packages
        echo "Removing Kubernetes packages..."
        apt-get remove -y kubeadm kubectl kubelet kubernetes-cni
        apt-get purge -y kube* --auto-remove

        # Optionally, remove Docker and Containerd if they were used for Kubernetes
        echo "Removing Docker, Containerd and associated images (optional)..."
        docker image prune -a -f
        systemctl restart docker
        apt-get purge -y docker-engine docker docker.io docker-ce docker-ce-cli containerd containerd.io runc --allow-change-held-packages
        apt-get autoremove -y

        # Remove Kubernetes, etcd, Docker, and Containerd related directories
        echo "Removing Kubernetes, etcd, Docker, and Containerd directories..."
        rm -rf ~/.kube
        rm -rf /etc/cni /etc/kubernetes /var/lib/dockershim /var/lib/etcd /var/lib/kubelet /var/run/kubernetes /usr/local/bin/kubeadm \
                /usr/local/bin/etcd /usr/local/bin/kubelet /usr/local/bin/kubectl \
                /etc/ssl/etcd
        rm -rf /var/lib/docker /etc/docker /var/run/docker.sock /var/lib/containerd /etc/containerd
        rm -f /etc/apparmor.d/docker /etc/systemd/system/docker.service.d /etc/systemd/system/etcd* /etc/systemd/system/containerd.service

        # Optionally, delete the docker group
        echo "Deleting Docker group (optional)..."
        groupdel docker

        # Clear iptables rules related to Kubernetes
        echo "Clearing iptables rules..."
        iptables -F && iptables -X
        iptables -t nat -F && iptables -t nat -X
        iptables -t raw -F && iptables -t raw -X
        iptables -t mangle -F && iptables -t mangle -X

        echo "Kubernetes, Docker, and Containerd have been removed from the system."
        ;;
    * )
        echo "Operation cancelled by the user."
        exit
        ;;
esac
