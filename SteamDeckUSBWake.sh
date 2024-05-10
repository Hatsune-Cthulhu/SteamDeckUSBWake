#!/bin/bash

readarray -t devices < $HOME/devices.enabled

vendors="";
products="";
for device in "${devices[@]}"
do
    if [[ "${device:1}" == "#" ]] then
        continue;
    fi

    device=${device:0:9};
    split=(${device//:/ });
    vendors+="|${split[0]}";
    products+="|${split[1]}";
done
vendors="${vendors:1}";
products="${products:1}";

ports=($(grep . /sys/bus/usb/devices/*/idProduct | grep -Eo "([0-9]+-[0-9]+(\.[0-9]+)?)/idProduct:($products)$" | grep -Eo "[0-9]+-[0-9]+(\.[0-9]+)?"));

vendorPorts=($(grep . /sys/bus/usb/devices/*/idVendor | grep -Eo "([0-9]+-[0-9]+(\.[0-9]+)?)/idVendor:($vendors)$" | grep -Eo "[0-9]+-[0-9]+(\.[0-9]+)?"));

for vendorPort in "${vendorPorts[@]}"
do
  if [[ ! ${ports[@]} =~ $vendorPort ]] then
    ports=("${ports[@]/$vendorPort}");
  fi
done

for port in "${ports[@]}"
do
  sudo echo "enabled" > /sys/bus/usb/devices/$port/power/wakeup;
  echo "Wake from sleep $(grep . /sys/bus/usb/devices/$port/power/wakeup): $port";
done
