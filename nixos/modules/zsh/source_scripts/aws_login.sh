function check_aws_cli {
    if ! command -v aws &> /dev/null; then
        echo "AWS CLI not found. Installing..."
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        sudo ./aws/install
        if ! command -v aws &> /dev/null; then
        echo "Failed to install AWS CLI. Please install it manually."
        exit 1
        fi
    fi
    }

function check_pass {
    if ! command -v pass &> /dev/null; then
        echo "'pass' not found. Installing..."
        sudo apt-get update -y && sudo apt-get install pass -y
        if ! command -v pass &> /dev/null; then
        echo "Failed to install 'pass'. Please install it manually."
        exit 1
        fi
    fi
}

AWS_CREDENTIAL_STORE="aws_credentials"
AWS_CLI_PATH=$(which aws)
OS_TYPE=$(uname -s)

function store_credentials_in_keychain {
    local access_key="$1"
    local secret_key="$2"

    security add-generic-password -a "$USER" -s "$AWS_CREDENTIAL_STORE" -w "aws_access_key=$access_key;aws_secret_key=$secret_key" -U
    echo "AWS credentials securely stored in macOS Keychain."
}

function retrieve_credentials_from_keychain {
    local credentials=$(security find-generic-password -a "$USER" -s "$AWS_CREDENTIAL_STORE" -w 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        echo "AWS credentials not found in macOS Keychain."
        return 1
    fi

    local access_key=$(echo "$credentials" | awk -F ';' '{print $1}' | cut -d '=' -f2)
    local secret_key=$(echo "$credentials" | awk -F ';' '{print $2}' | cut -d '=' -f2)

    echo "$access_key"
    echo "$secret_key"
}

function store_credentials_in_pass {
    local access_key="$1"
    local secret_key="$2"

    if ! pass show "$AWS_CREDENTIAL_STORE" &>/dev/null; then
        echo "'pass' is not initialized. Attempting to initialize it."
        local gpg_key=$(gpg --list-secret-keys --keyid-format LONG | grep -oP '\d{4}\/[0-9A-F]{16}' | cut -d '/' -f2)
        if [[ -z "$gpg_key" ]]; then
        echo "No GPG key found. Please generate a GPG key and try again."
        echo "You can create a GPG key with the following command:"
        echo "gpg --full-generate-key"
        exit 1
        fi
        pass init "$gpg_key"
    fi

    echo -e "aws_access_key=$access_key\naws_secret_key=$secret_key" | pass insert -m "$AWS_CREDENTIAL_STORE"
    echo "AWS credentials securely stored in 'pass'."
}

function retrieve_credentials_from_pass {
    local credentials=$(pass show "$AWS_CREDENTIAL_STORE" 2>/dev/null)
    if [[ $? -ne 0 ]]; then
        echo "AWS credentials not found in 'pass'."
        return 1
    fi

    local access_key=$(echo "$credentials" | grep "aws_access_key" | cut -d '=' -f2)
    local secret_key=$(echo "$credentials" | grep "aws_secret_key" | cut -d '=' -f2)

    echo "$access_key"
    echo "$secret_key"
}

function store_credentials {
    local access_key="$1"
    local secret_key="$2"

    if [[ "$OS_TYPE" == "Darwin" ]]; then
        store_credentials_in_keychain "$access_key" "$secret_key"
    else
        store_credentials_in_pass "$access_key" "$secret_key"
    fi
}

function retrieve_credentials {
    if [[ "$OS_TYPE" == "Darwin" ]]; then
        retrieve_credentials_from_keychain
    else
        retrieve_credentials_from_pass
    fi
}

function configure_aws_with_credentials {
    local access_key="$1"
    local secret_key="$2"

    if [[ -f "$HOME/.aws/credentials" ]]; then
        rm "$HOME/.aws/credentials"
        echo "Removed ~/.aws/credentials"
    else
        echo "~/.aws/credentials does not exist"
    fi

    aws configure set aws_access_key_id "$access_key"
    aws configure set aws_secret_access_key "$secret_key"
    echo "AWS CLI configured with credentials."
}

function configure_mfa_session {
    echo "Retrieving MFA devices..."
    local mfa_devices=$(aws iam list-mfa-devices --query 'MFADevices[*].SerialNumber' --output text 2>/dev/null)

    if [[ $? -ne 0 || -z "$mfa_devices" ]]; then
        echo "Error: Unable to retrieve MFA devices. Check your AWS credentials."
        exit 1
    fi

    local mfa_device_count=$(echo "$mfa_devices" | wc -w)

    if [[ "$mfa_device_count" -eq 1 ]]; then
        mfa_serial_number=$(echo "$mfa_devices" | awk '{print $1}')
        echo "Only one MFA device found. Automatically selected: $mfa_serial_number"
    elif [[ "$mfa_device_count" -gt 1 ]]; then
        echo "Available MFA devices:"
        echo "$mfa_devices"
        read "mfa_serial_number?Enter the MFA device serial number: "
    else
        echo "No MFA devices found. Please add an MFA device to your AWS account."
        exit 1
    fi

    read "mfa_token?Enter MFA token code: "

    local session=$(aws sts get-session-token --serial-number "$mfa_serial_number" --token-code "$mfa_token" 2>/dev/null)
    if [[ $? -ne 0 || -z "$session" ]]; then
        echo "Error: Unable to retrieve session token. Check your MFA token and try again."
        exit 1
    fi

    local access_key=$(echo "$session" | jq -r '.Credentials.AccessKeyId')
    local secret_key=$(echo "$session" | jq -r '.Credentials.SecretAccessKey')
    local session_token=$(echo "$session" | jq -r '.Credentials.SessionToken')

    aws configure set aws_access_key_id "$access_key"
    aws configure set aws_secret_access_key "$secret_key"
    aws configure set aws_session_token "$session_token"

    echo "AWS CLI configured with temporary session credentials."
    }

    function new_aws_login {
    local reset_credentials=false

    zparseopts -D -E r=reset_flag

    if [[ -n "$reset_flag" ]]; then
        reset_credentials=true
    fi

    check_aws_cli
    check_pass

    if $reset_credentials; then
        echo "Resetting AWS credentials..."
        read "access_key?Enter AWS Access Key ID: "
        read -s "secret_key?Enter AWS Secret Access Key: "
        echo ""
        store_credentials "$access_key" "$secret_key"
    fi

    local credentials=$(retrieve_credentials)
    if [[ $? -ne 0 ]]; then
        echo "AWS credentials not found. Creating new credentials."
        read "access_key?Enter AWS Access Key ID: "
        read -s "secret_key?Enter AWS Secret Access Key: "
        echo ""
        store_credentials "$access_key" "$secret_key"
        credentials=$(retrieve_credentials)
    fi

    local access_key=$(echo "$credentials" | head -n 1)
    local secret_key=$(echo "$credentials" | tail -n 1)

    configure_aws_with_credentials "$access_key" "$secret_key"

    read "configure_mfa?Do you want to configure an MFA session? (y/n): "
    if [[ "$configure_mfa" == "y" ]]; then
        configure_mfa_session
    fi
}
