if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Allow reading instruction counters
echo "2" > /sys/bus/event_source/devices/cpu/rdpmc
# Allow PAPI from reading performance counters
echo "0" > /proc/sys/kernel/perf_event_paranoid
