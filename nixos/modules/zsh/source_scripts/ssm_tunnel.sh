# Function to open SSM tunnel session
open_ssm_tunnel_session() {
    local server_name="$1"
    local local_port="${2:-222}"
    local destination_port="${3:-22}"

    # Get the EC2 instance ID based on the instance name
    target=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=$server_name" "Name=instance-state-name,Values=running" \
        --query "Reservations[*].Instances[*].InstanceId" \
        --output text)

    if [ -z "$target" ]; then
        echo "Error: No EC2 instance found with name '$server_name' or the instance is not running"
        exit 1
    elif [ $(echo "$target" | wc -l) -gt 1 ]; then
        echo "Error: Multiple EC2 instances found with name '$server_name'. Please refine the open_ssm_tunnel_session with additional filters."
        exit 1
    else
        # Start the SSM session with port forwarding
        aws ssm start-session \
            --target "$target" \
            --document-name "AWS-StartPortForwardingSession" \
            --parameters "{\"portNumber\":[\"$destination_port\"],\"localPortNumber\":[\"$local_port\"]}"
    fi
}