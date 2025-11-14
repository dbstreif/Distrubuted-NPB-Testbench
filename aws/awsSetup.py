from python_terraform import Terraform
import ansible_runner
import tempfile
import os
import json

print("AWS NPB Testbench")

# Initialize the Terraform working directory
tf = Terraform(working_dir='.')

print("Starting init...")
retcode, stdout, stderr = tf.init()
print(stderr)

print("Starting apply...")
retcode, stdout, stderr = tf.apply(skip_plan=True)
print(stderr)


data = tf.output(json=True)

slotNum = 2
masterPubIp = data["node_pubips"]["value"][0]
secondPubIp = data["node_pubips"]["value"][1]
thirdPubIp = data["node_pubips"]["value"][2]

masterPrivIp = data["node_privips"]["value"][0]
secondPrivIp = data["node_privips"]["value"][1]
thirdPrivIp = data["node_privips"]["value"][2]

# Create hosts file
print("Creating hosts file...")

hostsFile = "../hosts"
with open(hostsFile, 'w') as file:
    file.write(f"{masterPrivIp} slots={slotNum}\n")
    file.write(f"{secondPrivIp} slots={slotNum}\n")
    file.write(f"{thirdPrivIp} slots={slotNum}\n")

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

print("Starting ansible...")

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
