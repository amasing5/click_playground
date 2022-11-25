import sys
import os
import subprocess
import json
import chevron
import logging
from collections import defaultdict


def get_intf_info_map(in_ip, out_ip):
    
    # Get interface names
    in_intf, err = get_intf(in_ip)
    assert err is None
    out_intf, err = get_intf(out_ip)
    assert err is None

    # Get MAC addresses
    in_mac, err = get_mac(in_intf)
    assert err is None
    out_mac, err = get_mac(out_intf)
    assert err is None

    data_map = defaultdict()
    data_map['in_intf'] = in_intf
    data_map['out_intf'] = out_intf
    data_map['in_ip'] = in_ip
    data_map['out_ip'] = out_ip
    data_map['in_mac'] = in_mac
    data_map['out_mac'] = out_mac

    return data_map


def get_intf(ip_addr):
    netstat = subprocess.Popen(["netstat", "-ie"],
          stdout=subprocess.PIPE,
          stderr=subprocess.STDOUT)
    grep = subprocess.Popen(["grep", "-B1", ip_addr],
          stdin=netstat.stdout, 
          stdout=subprocess.PIPE,
          stderr=subprocess.STDOUT)
    head = subprocess.Popen(["head", "-n1"],
          stdin=grep.stdout,
          stdout=subprocess.PIPE, 
          stderr=subprocess.STDOUT)
    out = subprocess.Popen(["awk", "-F", ":", "{print $1}"],
          stdin=head.stdout, 
          stdout=subprocess.PIPE,
          stderr=subprocess.STDOUT)
    intf, stderr = out.communicate()
    return intf.strip(), stderr

def get_mac(intf):
    out = subprocess.Popen(["cat", "/sys/class/net/{}/address".format(intf)],
          stdout=subprocess.PIPE,
          stderr=subprocess.STDOUT)
    mac, stderr = out.communicate()
    return mac.strip(), stderr

def main(file_path, click_path):
    # Check for mandatory environmen variables.
    in_ip = None
    if "IN_IP" not in os.environ:
        print("IN_IP environment variable is not set. IN_IP, OUT_IP must be set before calling this script.")
        sys.exit(1)
    in_ip = os.environ["IN_IP"]

    out_ip = None
    if "OUT_IP" not in os.environ:
        print("OUT_IP environment variable is not set. IN_IP, OUT_IP must be set before calling this script.")
        sys.exit(1)
    out_ip = os.environ["OUT_IP"]
    
    generated_file_path = generate_click_config(in_ip, out_ip, file_path)
    if click_path is not None and generated_file_path is not None:
        run_click(click_path, generated_file_path)

def generate_click_config(in_ip, out_ip, file_path):
    intf_info = get_intf_info_map(in_ip, out_ip)
    generated_file_path = None
    with open(file_path, 'r') as f:
        contents = chevron.render(f, intf_info)
        dir = os.path.dirname(file_path)
        generated_dir = os.path.join(dir, "runtime")
        if not os.path.exists(generated_dir):
            os.makedirs(generated_dir)
            os.chmod(generated_dir, 0o777)
        generated_file_path = os.path.join(generated_dir, os.path.basename(file_path))
        with open(generated_file_path, 'w') as gf:
            gf.write(contents)
            print("Generated file {}".format(generated_file_path))
    os.chmod(generated_file_path, 0o666)
    return generated_file_path

def run_click(click_path, generate_click_config):
    print("Disable IP-Forwarding ")
    subprocess.call(["sysctl", "-w", "net.ipv4.ip_forward=0"])
    print("Running click: {} {}".format(click_path, generate_click_config))
    subprocess.call([click_path, generate_click_config])

# Stand Alone execution
if __name__ == "__main__":
    args = sys.argv
    click_path = None
    if len(args) < 2 or len(args) > 3:
        print("Usage: generate_router.py <click config file> [<click_executable_path>]")
        sys.exit(1)
    main(args[1], (args[2] if len(args) == 3 else None))
