import boto3

def stop_ec2_instances(region):
    ec2 = boto3.resource("ec2", region_name=region)
    filters = [
        {
            "Name": "instance-state-name",
            "values": "running"
        }
    ]
    for instance in ec2.instances.filter(Filters = filters ):
        instance.stop()




def start_ec2_instances(region):
    ec2 = boto3.resource("ec2", region_name=region)
    filters = [
        {
            "Name": "instance-state-name",
            "values": "stopped"
        }
    ]
    for instance in ec2.instances.filter(Filters = filters ):
        instance.start()




def lambda_handler(event, context):
    
    region = 'eu-west-1'
 
    if (event.get('action') == 'start'):
        instance_state = start_ec2_instances(region)
    elif (event.get('action') == 'stop'):
        instance_state = stop_ec2_instances(region)

    return instance_state