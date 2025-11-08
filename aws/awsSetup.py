from python_terraform import Terraform
import ansible_runner
import tempfile
import os
import json

# Initialize the Terraform working directory
tf = Terraform(working_dir='.')
tf.init()
tf.plan()
tf.apply(skip_plan=True)

data = tf.output(json=True)

slotNum = 2
masterPubIp = data["node1_pubip"]["value"]
secondPubIp = data["node2_pubip"]["value"]
thirdPubIp = data["node3_pubip"]["value"]

# Create hosts file
hostsFile = "../hosts"
with open(hostsFile, 'w') as file:
    file.write(f"{masterPubIp} slots={slotNum}\n")
    file.write(f"{secondPubIp} slots={slotNum}\n")
    file.write(f"{thirdPubIp} slots={slotNum}\n")

# Start ansbile runner with special inventory

scriptDir = os.path.dirname(os.path.abspath(__file__)) 
privKeyPath = os.path.join(scriptDir, '..', 'ansible', 'keys', 'clientkey.pem')

inventoryData = {
        'all': {
            'vars': {
                'ansible_user': 'ubuntu',
                'ansible_ssh_private_key_file': privKeyPath,
                'ansible_ssh_common_args': "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
            },
            'children': {
                'machines': {
                    'hosts': {
                        masterPubIp: {},
                        secondPubIp: {},
                        thirdPubIp: {}
                }
            }
        }
    }
}


playFile = '../ansible/playbook.yaml'
playAbsPath = os.path.abspath(os.path.join(os.path.dirname(__file__), playFile))

with tempfile.TemporaryDirectory() as tempDir:
    r = ansible_runner.run(
            private_data_dir=tempDir,
            playbook=playAbsPath,
            inventory=inventoryData
    )


# Clean up
os.remove(hostsFile)

print(f"Ansible status: {r.status}")

print(f"Access controller node at: {masterPubIp}")
print(f"Access second node at: {secondPubIp}")
print(f"Access third node at: {thirdPubIp}")
