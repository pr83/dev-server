{% for hostname in additionalHostMachineHostnames %}
    echo "{{ ansible_default_ipv4.address }} {{ hostname }}" >> /etc/hosts
{% endfor %}

/usr/local/bin/jenkins.sh